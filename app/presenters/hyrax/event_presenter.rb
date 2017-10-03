module Hyrax
  class EventPresenter
    attr_accessor :event, :current_ability, :request

    # @param [Hyrax::Preservation::Event] event
    # @param [Ability] current_ability
    def initialize(event, current_ability, request = nil)
      @event = event
      @current_ability = current_ability
      @request = request
    end

    def type_display
      Hyrax::Preservation::PremisEventType.find_by_abbr(event[:premis_event_type_ssim]&.first)&.label || "Unknown Event Type"
    end

    def type_link
      Hyrax::Preservation::Engine.routes.url_helpers.events_path(related_object: related_object, 'premis_event_type[]' => type_code)
    end

    def event_link
      Hyrax::Preservation::Engine.routes.url_helpers.event_path(event[:id])
    end

    def type_code
      event[:premis_event_type_ssim]&.first
    end

    def related_object
      event[:hasEventRelatedObject_ssim]&.first
    end

    def outcome
      event[:premis_event_outcome_tesim]&.first
    end

    def date
      event[:premis_event_date_time_dtsim]&.first
    end

    def agent
      event[:premis_agent_ssim]&.first
    end
  end
end
