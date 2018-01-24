require 'hyrax/preservation'

class FixityCheckJob < ActiveJob::Base

  queue_as :fixity_check

  def initialize(options={})
    # TODO: better validation of user option
    raise ArgumentError, "Required option :user is missing" unless options[:user]
    raise ArgumentError, "Option :ids should be an array of FileSet IDs" unless options[:ids].respond_to? :each
    @user = options[:user]
    @ids = options[:ids]
  end

  def run
    logger.info "Running fixity check."
    check
    File.write('fixity_pass_fail_report.csv', pass_fail_report_csv)
  end

  private

    def check
      create_events(passing_docs,'pass')
      create_events(failing_docs,'fail')
    end

    def passing_docs
      @passing_docs ||= solr_docs_for_fixity_check.select do |doc|
        !doc.current_mes_event_changed?
      end
    end

    def failing_docs
      @failing_docs ||= solr_docs_for_fixity_check.select do |doc|
        doc.current_mes_event_changed?
      end
    end

    def user_email
      @user_email ||= if @user.respond_to? :email
        @user.email
      else
        @user.to_s
      end
    end

    def premis_agent_uri
      ::RDF::URI.new('mailto:' + user_email)
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
        premis_agent: [ premis_agent_uri ],
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

    def pass_fail_report_csv
      @pass_fail_report_csv ||= begin
        csv = ["ID,STATUS"]
        csv += passing_docs.map { |doc| "#{doc.id},pass" }
        csv += failing_docs.map { |doc| "#{doc.id},fail" }
        csv.join("\n")
      end
    end
end