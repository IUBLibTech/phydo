require 'hyrax/preservation'

module Phydo
  class FileSetPresenter < ::Hyrax::FileSetPresenter
    include ActionView::Helpers::UrlHelper

    def link_name
      current_ability.can?(:read, id) ? filename : 'File'
    end

    def member_presenters
      files.map { |file| ::Hyrax::FilePresenter.new(file, @current_ability, @request) }
    end

    def recent_event_presenters
      @solr_document.recent_preservation_events.map { |event| ::Hyrax::EventPresenter.new(event, @current_ability, @request) }
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

    def deaccessioned?
      @solr_document.recent_preservation_events.select { |e| e['premis_event_type_ssim']&.first == 'dea' && e['premis_event_outcome_tesim']&.first&.match(/(succ|pass)/i) }.any?
    end
  end
end
