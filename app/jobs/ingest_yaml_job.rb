require 'hyrax/preservation'
require 'external_storage/config'

class IngestYAMLJob < ActiveJob::Base
  queue_as :ingest

  # @param [String] yaml_file Filename of a YAML file to ingest
  # @param [String] user User to ingest as
  def perform(yaml_file, user)
    logger.info "Ingesting YAML #{yaml_file}"
    @yaml_file = yaml_file
    @yaml = File.open(yaml_file) { |f| HashWithIndifferentAccess.new(YAML.safe_load(f)) }
    @user = user
    ingest
  end

  private

    def ingest
      if @yaml[:work]
        resource = Work.new
        resource.attributes = translate_properties(resource,@yaml[:work])
        resource.visibility = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_AUTHENTICATED
        resource.apply_depositor_metadata @user
        resource.save!
        logger.info "Created #{resource.class}: #{resource.id}"
      else
        resource = nil
        logger.info "No parent resource specified."
      end

      ingest_file_sets(resource: resource, files: @yaml[:filesets])
      resource.save! if resource
      logger.info "Ingested #{resource.class}: #{resource.id} with #{resource.file_sets.count} files."
    end

    def ingest_file_sets(parent: nil, resource: nil, files: [])
      files.select { |k, v| v[:file_name].present? }.each do |k, v|
        logger.info "Ingesting FileSet for #{v[:file_name]}"
        file_set = FileSet.new
        file_set.attributes = translate_properties(file_set, v)
        file_set.visibility = resource.visibility
        file_set.apply_depositor_metadata(@user)
        file_set.save!
        resource.ordered_members << file_set
        actor = Phydo::FileSetActor.new(file_set, @user)
        ingest_external_file(resource, file_set, actor, [v])
        add_ingestion_event(file_set)
      end
    end

    def external_uri_for(file_params)
      "#{ExternalStorage::Config.config.external_uri_host}/#{file_params[:file_path].first}"
    end

    def field_map
      @field_map ||= {
          file_size: :format_file_size,
          duration: :format_duration,
          sample_rate: :format_sample_rate,
          use: :quality_level,
          checksum: :md5_checksum
      }.with_indifferent_access
    end

    def translate_properties(object, properties)
      # Perform field name remapping
      field_map.each do |key, value|
        if properties.key?(key) && object.class.attribute_method?(value)
          properties[value] = properties.delete(key)
        end
      end

      # Wrap any scalars that are going into multivalued fields
      properties.each do |key, value|
        if object.class.multiple? key
          properties[key] = Array.wrap value
        end
      end
    end

    def ingest_external_file(resource, file_set, actor, files)
      # require './lib/phydo/file_actor/ingest_file_now.rb'
      # Hyrax::Actors::FileActor.prepend ::Phydo::FileActor::IngestFileNow
      files.each_with_index do |file, i|
        logger.info "FileSet #{file_set.id}: ingesting file: #{file[:file_name]}"
        actor.create_metadata(file[:file_opts]) if i.zero? && file[:file_path]
        # TODO: fix hyrax characterization bug; workaround immediately below
        file_set.class.characterization_proxy = file[:use] || :original_file
        actor.create_content(file[:file_name], external_uri_for(file), file[:use]) if file[:file_path] #FIXME: handle purl case
      end
    end

    def ingest_events(file_set, events)
      events.each do |event|
        logger.info "FileSet #{file_set.id}: adding event: #{event[:attributes][:premis_event_type]&.join(', ')}"
        add_event(file_set, event[:attributes])
      end
    end

    def add_event(file_set, event_attributes, prep_attributes: true)
      e = Hyrax::Preservation::Event.new
      e.premis_event_related_object = file_set
      if prep_attributes
        event_attributes[:premis_event_type] = event_attributes[:premis_event_type].map do |pet|
          Hyrax::Preservation::PremisEventType.new(pet).uri
        end
        event_attributes[:premis_agent] = event_attributes[:premis_agent].map do |agent|
          ::RDF::URI.new(agent)
        end
        event_attributes[:premis_event_date_time] = event_attributes[:premis_event_date_time].map do |date_time|
          DateTime.parse(date_time.to_s)
        end
      end
      e.attributes = event_attributes
      e.save!
    end
      
    def add_ingestion_event(file_set)
      ing_event = {}
      ing_event[:attributes] = {
        premis_event_type: ['ing'],
        premis_agent: ['mailto:' + @user.email],
        premis_event_outcome: ['SUCCESS'],
        premis_event_date_time: [DateTime.now]
      }
      mes_event = {}
      mes_event[:attributes] = {
          premis_event_type: ['mes'],
          premis_agent: ['mailto:' + @user.email],
          premis_event_outcome: [file_set.md5_checksum.first.to_s],
          premis_event_detail: ['From ingestion package'],
          premis_event_date_time: [DateTime.now]
      }
      ingest_events(file_set, [ing_event, mes_event])
    end
end
