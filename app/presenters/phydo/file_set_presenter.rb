require 'hyrax/preservation'

module Phydo
  class FileSetPresenter < ::Hyrax::FileSetPresenter
    include ActionView::Helpers::UrlHelper

    delegate :identifier, :date_generated, :file_format, :audio_codec_type, :video_codec_type,
             :duration, :quality_level, :mdpi_timestamp, :file_size, :bit_rate, :md5_checksum,
             :video_width, :video_height, :format_sample_rate, :quality_level,
             to: :solr_document

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
  end
end
