module CurationConcerns
  class FilePresenter
    attr_accessor :file, :current_ability, :request

    # @param [Hydra::PCDM::File] file
    # @param [Ability] current_ability
    def initialize(file, current_ability, request = nil)
      @file = file
      @current_ability = current_ability
      @request = request
    end

    def thumbnail
      file.model_type.select { |t| t.to_uri.to_s.match /use#/ }.first.to_s.sub(/.*#/, '')
    end

    def filename
      file.file_name&.first.to_s
    end

    def date_uploaded
      file.date_created.first
    end

    def uri
      file.uri.to_s
    end
  end
end
