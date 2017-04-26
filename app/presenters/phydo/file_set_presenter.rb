module Phydo
  class FileSetPresenter < ::Hyrax::FileSetPresenter
    include ActionView::Helpers::UrlHelper

    def link_name
      current_ability.can?(:read, id) ? filename : 'File'
    end

    def member_presenters
      files.map { |file| ::Hyrax::FilePresenter.new(file, @current_ability, @request) }
    end

    def files
      ActiveFedora::Base.find(@solr_document[:id]).files
    end

    def system_create
      DateTime.parse(solr_document.system_create).strftime("%Y-%m-%d %H:%I:%S")
    end

    def system_modified
      DateTime.parse(solr_document.system_modified).strftime("%Y-%m-%d %H:%I:%S")
    end

    # @note TODO: It would be nice to just have this presenter delegate
    # #preservation_events to #solr_document and handle html-specific stuff in
    # a custom renderer. However, the #render and #attribute_value_to_html
    # methods in CurationConcerns::Renderers::AttributeRenderer needs to be
    # refactored just a bit to handle structured data from a SolrDocument
    # instance. So instead we just have this method mark up the attr values.
    def preservation_events
      solr_document.preservation_events.map do |preservation_event|
        premis_event_type_label = Preservation::PremisEventType.find_by_abbr(preservation_event[:premis_event_type_ssim]&.first)&.label || "Unknown Event Type"
        link_to premis_event_type_label, Preservation::Engine.routes.url_helpers.event_path(preservation_event[:id])
      end.join('<br />').html_safe
    end
  end
end
