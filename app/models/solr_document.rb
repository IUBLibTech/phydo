require 'hyrax/preservation'

# frozen_string_literal: true
class SolrDocument
  include Blacklight::Solr::Document
  include Blacklight::Gallery::OpenseadragonSolrDocument

  # Adds Hyrax behaviors to the SolrDocument.
  include Hyrax::SolrDocumentBehavior


  # self.unique_key = 'id'

  # Email uses the semantic field mappings below to generate the body of an email.
  SolrDocument.use_extension(Blacklight::Document::Email)

  # SMS uses the semantic field mappings below to generate the body of an SMS email.
  SolrDocument.use_extension(Blacklight::Document::Sms)

  # DublinCore uses the semantic field mappings below to assemble an OAI-compliant Dublin Core document
  # Semantic mappings of solr stored fields. Fields may be multi or
  # single valued. See Blacklight::Document::SemanticFields#field_semantics
  # and Blacklight::Document::SemanticFields#to_semantic_values
  # Recommendation: Use field names from Dublin Core
  use_extension(Blacklight::Document::DublinCore)

  # Do content negotiation for AF models.

  use_extension( Hydra::ContentNegotiation )

  def filename
    @filename ||= begin
      full_filename = fetch(Solrizer.solr_name(:file_name, :stored_searchable)).first
      if full_filename
        File.basename(full_filename)
      else
        'Unknown'
      end
    end
  end

  def file_size
    fetch(Solrizer.solr_name(:file_size, Solrizer::Descriptor.new(:long, :stored, :indexed)), [])
  end

  def file_path
    fetch(Solrizer.solr_name(:file_path, :symbol), [])
  end

  def quality_level
    fetch(Solrizer.solr_name(:quality_level, :stored_searchable), [])
  end

  def digitized_by_entity
    fetch(Solrizer.solr_name(:digitized_by_entity, :stored_searchable), [])
  end

  def digitized_by_staff
    fetch(Solrizer.solr_name(:digitized_by_staff, :stored_searchable), [])
  end

  def mdpi_timestamp
    fetch('mdpi_timestamp_isi', [])
  end

  def md5_checksum
    fetch(Solrizer.solr_name(:md5_checksum, :symbol), [])
  end

  def system_create
    fetch(Solrizer.solr_name(:system_create, :stored_sortable, type: :date), [])
  end

  def system_modified
    fetch(Solrizer.solr_name(:system_modified, :stored_sortable, type: :date), [])
  end

  def extraction_workstation
    fetch(Solrizer.solr_name(:extraction_workstation, :stored_searchable), [])
  end

  def digitization_comments
    fetch(Solrizer.solr_name(:digitization_comments, :stored_searchable), [])
  end

  def original_identifier
    fetch(Solrizer.solr_name(:original_identifier, :symbol), [])
  end

  def definition
    fetch(Solrizer.solr_name(:definition, :stored_searchable), [])
  end

  def date_generated
    fetch(Solrizer.solr_name(:date_generated, :stored_searchable), [])
  end

  def file_format_long_name
    fetch(Solrizer.solr_name(:file_format_long_name, :symbol), [])
  end

  def audio_codec_type
    fetch(Solrizer.solr_name(:audio_codec_type, :stored_searchable), [])
  end

  def video_codec_type
    fetch(Solrizer.solr_name(:video_codec_type, :stored_searchable), [])
  end

  def codec_name
    fetch(Solrizer.solr_name(:codec_name, :stored_searchable), [])
  end

  def codec_long_name
    fetch(Solrizer.solr_name(:codec_long_name, :stored_searchable), [])
  end

  def video_width
    fetch(Solrizer.solr_name(:video_width, :stored_searchable), [])
  end

  def video_height
    fetch(Solrizer.solr_name(:video_height, :stored_searchable), [])
  end

  def format_duration
    fetch(Solrizer.solr_name(:format_duration, :stored_searchable), [])
  end

  def bit_rate
    fetch(Solrizer.solr_name(:bit_rate, :stored_searchable), [])
  end

  def format_sample_rate
    fetch(Solrizer.solr_name(:format_sample_rate, :stored_searchable), [])
  end

  def unit_of_origin
    fetch(Solrizer.solr_name(:unit_of_origin, :stored_searchable), [])
  end

  def mdpi_barcode
    fetch(Solrizer.solr_name(:mdpi_barcode, :symbol), [])
  end

  def recording_standard
    fetch(Solrizer.solr_name(:recording_standard, :stored_searchable), [])
  end

  def original_format
    fetch(Solrizer.solr_name(:original_format, :stored_searchable), [])
  end

  def image_format
    fetch(Solrizer.solr_name(:image_format, :stored_searchable), [])
  end

  def preservation_events
    @preservation_events ||= Hyrax::Preservation::Event.search_with_conditions(hasEventRelatedObject_ssim: fetch(:id))
  end

  def recent_preservation_events
    @recent_preservation_events ||= begin
      recents = []
      types = preservation_events.map { |pe| pe[:premis_event_type_ssim]&.first }.uniq
      types.each do |type|
        events = preservation_events.select { |pe| pe[:premis_event_type_ssim]&.first == type }
        recents << events.max { |e1, e2| e1[:premis_event_date_time_dtsim]&.first.to_s <=> e2[:premis_event_date_time_dtsim]&.first.to_s }
      end
      recents
    end
  end

  def mes_events
    @mes_events ||= begin
      Hyrax::Preservation::Event.search_with_conditions(hasEventRelatedObject_ssim: fetch(:id), premis_event_type_ssim: 'mes')
    end.sort_by do |mes|
      # Sort first by premis event date time, if found; otherwise by the system create date.
      mes["premis_event_date_time_dtsim"] || mes['system_create_dtsi']
    end
  end

  def current_mes_event
    mes_events.last
    # @current_mes_event ||= Hyrax::Preservation::Event.find(mes_events&.sort_by { |dt| dt["premis_event_date_time_dtsim"] }&.last&.id)
  end

  def previous_mes_event
    mes_events[-2]
    # @previous_mes_event ||= Hyrax::Preservation::Event.find(mes_events&.sort_by { |dt| dt["premis_event_date_time_dtsim"] }[-2]&.id)
  end

  def current_mes_event_changed?
    !!( current_mes_event && previous_mes_event && (current_mes_event['premis_event_outcome_tesim'] != previous_mes_event['premis_event_outcome_tesim']) )
  end

  def hardware
    fetch(Solrizer.solr_name(:hardware, :stored_searchable), [])
  end

end
