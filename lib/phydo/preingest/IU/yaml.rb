# FIXME: better configure library includes
require './lib/phydo/preingest/attribute_ingester.rb'

module Phydo
  module Preingest
    module IU
      class Yaml
        def initialize(preingest_file)
          @preingest_file = preingest_file
          @yaml = File.open(preingest_file) { |f| Psych.load(f) }
          parse
        end
        attr_reader :preingest_file
        attr_reader :work_attributes, :file_set_attributes, :file_sets

        def resource_class
          @yaml[:resource].constantize if @yaml[:resource]
        end

        def parse
          @work_attributes = Phydo::Preingest::AttributeIngester.new(@preingest_file, @yaml[:work_attributes], factory: resource_class).raw_attributes
          @file_sets = @yaml[:file_sets]
          @file_sets.select { |fs| fs[:attributes].present? }.each do |file_set|
            file_set[:attributes] = Phydo::Preingest::AttributeIngester.new(@preingest_file, file_set[:attributes], factory: FileSet).raw_attributes
          end
        end
      end
    end
  end
end
