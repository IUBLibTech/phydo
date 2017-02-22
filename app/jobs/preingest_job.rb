class PreingestJob < ActiveJob::Base
  queue_as :preingest

  def perform(package_class, preingest_file, user)
    logger.info "Preingesting #{package_class} #{preingest_file}"
    @preingest_file = preingest_file
    @package_reader = package_class.new(preingest_file)
    @user = user

    preingest
  end

  private

    def preingest
      @yaml_hash = {}
      @yaml_hash[:resource] = @package_reader.resource_class.to_s if @package_reader.try(:resource_class)
      @yaml_hash[:work_attributes] = @package_reader.work_attributes if @package_reader.try(:work_attributes)
      @yaml_hash[:file_sets] = @package_reader.file_sets

      output_file = @preingest_file.gsub(/\..{3,4}/, '.yml')
      File.write(output_file, @yaml_hash.to_yaml)
      logger.info "Created YAML file #{output_file}"
    end
end
