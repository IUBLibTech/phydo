require 'hyrax/preservation'

class FixityCheckJob < ActiveJob::Base
  queue_as :fixity_check

  def initialize(options={})
    raise ArgumentError, "Required option :user is missing" unless options.key?(:user)
    raise ArgumentError, "Required option :ids is missing" unless options.key?(:ids)
    raise ArgumentError, "Option :ids should be an array of FileSet IDs" unless options[:ids].is_a?(Array)
    @user = options[:user]
    @ids = options[:ids]
  end

  def run
    logger.info "Running fixity check."
    check
  end

  private

    def check
      passing_docs = []
      failing_docs = []
      solr_docs_for_fixity_check.each do |doc|
        passing_docs << doc if !doc.current_mes_event_changed?
        failing_docs << doc if doc.current_mes_event_changed?
      end
      create_events(passing_docs,'pass')
      create_events(failing_docs,'fail')
    end

    def solr_docs_for_fixity_check
      solr_doc_ids_for_fixity_check.map { |id| SolrDocument.find(id) }
    end

    def solr_doc_ids_for_fixity_check
      Hyrax::Preservation::Event.where(premis_event_type_ssim: 'mes').select { |mes| @ids.include?(mes[:premis_event_related_object_id]) }.map { |mes| mes.premis_event_related_object_id }.uniq
    end

    def create_events(docs,status)
      docs.each do |doc|
        logger.info "FileSet #{doc.id}: adding PREMIS Fixity Check with a status of: #{status}"
        add_event(doc.id, event_attributes(status))
      end
    end

    def event_attributes(status)
      event_attributes = {
        premis_event_type: [ Hyrax::Preservation::PremisEventType.new('fix').uri ],
        premis_agent: [ ::RDF::URI.new('mailto:' + @user.email) ],
        premis_event_outcome: [ status ],
        premis_event_date_time: [ DateTime.now ]
      }
    end

    def add_event(doc_id,event_attrs)
      e = Hyrax::Preservation::Event.new
      e.attributes = event_attrs
      e.premis_event_related_object = FileSet.find(doc_id)
      e.save!
    end
end
