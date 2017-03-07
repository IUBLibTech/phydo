module CurationConcerns
  class FileSetPresenter
    include ModelProxy
    include PresentsAttributes
    attr_accessor :solr_document, :current_ability

    include ActionView::Helpers::UrlHelper
    include Preservation::Engine.routes.url_helpers

    # @param [SolrDocument] solr_document
    # @param [Ability] current_ability
    def initialize(solr_document, current_ability, request = nil)
      @solr_document = solr_document
      @current_ability = current_ability
      @request = request
    end

    # TODO: replace this?
    def single_use_links
      []
    end

    # CurationConcern methods
    delegate :stringify_keys, :human_readable_type, :collection?, :image?, :video?,
             :audio?, :pdf?, :office_document?, :representative_id, :to_s, to: :solr_document

    # Methods used by blacklight helpers
    delegate :has?, :first, :fetch, to: :solr_document

    # Metadata Methods
    delegate :title, :description, :creator, :contributor, :subject, :publisher,
             :language, :date_uploaded, :rights,
             :embargo_release_date, :lease_expiration_date,
             :depositor, :tags, :title_or_label, to: :solr_document

    delegate :filename, :file_format, :file_format_long_name, :file_size, :original_checksum, :quality_level,
             :date_generated, :codec_type, :codec_name, :codec_long_name, :duration, :mdpi_timestamp,
             :bit_rate, :unit_of_origin, :mdpi_barcod,
             to: :solr_document

    def page_title
      Array.wrap(solr_document['label_tesim']).first
    end

    def link_name
      current_ability.can?(:read, id) ? filename : 'File'
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
        premis_event_type_label = Preservation::Event.premis_event_type(preservation_event[:premis_event_type_ssim]&.first).label || "Unknown Event Type"
        link_to premis_event_type_label, Preservation::Engine.routes.url_helpers.event_path(preservation_event[:id])
      end.join('<br />').html_safe
    end
  end
end
