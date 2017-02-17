require './lib/hydradam/preingest/attribute_ingester.rb'

module HydraDAM
  module Preingest
    module WGBH
      class SIP
        def initialize(preingest_file)
          @preingest_file = preingest_file
          parse
        end
        
        attr_reader :preingest_file
        attr_reader :work_attributes, :file_set_attributes, :source_metadata, :file_sets, :sources
  
        def resource_class
          Work
        end

        def source_metadata
          nil
        end
        
        def parse
          @file_sets = []
          filenames.each { |filename| process_file(filename) }
        end
        
        def filenames
          @filenames ||= [preingest_file, preingest_file.sub('_pbcore','')]
        end
        
        def process_file(filename)
          file_set = { filename: filename.sub(/.*\//, '') }
          file_reader = HydraDAM::Preingest::WGBH::FileReader.new(filename)
          unless file_reader&.type.nil?
            file_set_ai = HydraDAM::Preingest::AttributeIngester.new(file_reader.id, file_reader.file_attributes, factory: FileSet)
            file_set[:attributes] = file_set_ai.raw_attributes
            file_set[:files] = file_reader.files
            file_set[:events] = file_reader.events if file_reader.events
          end
          @file_sets << file_set if file_set.present?
        end
      end

      class FileReader
        def initialize(filename)
          @filename = filename
          @reader = reader_class.new(filename, File.read(filename))
        end
        
        attr_reader :filename, :reader
        delegate :id, :attributes, :file_attributes, :files, :events, :type, to: :reader
  
        def reader_class
          case @filename
          when /pbcore\.xml$/
            PbcoreReader
          when /fits\.xml$/
            FitsReader
          else
            NullReader # raise exception?
          end
        end
      end
      
      class NullReader
        def initialize(id, source)
          @id = id
          @source = source
        end
        attr_reader :id, :source
  
        def type
          nil
        end
        
        def attributes
          {}
        end

        def events
          nil
        end
      end

      class AbstractReader
        def initialize(id, source)
          @id = id
          @source = source
          @mime_type = 'application/octet-stream'
        end
        attr_reader :id, :source, :mime_type
  
        def parse
        end

        # for Work metadata
        def attributes
          {}
        end
  
        # for fileset metadata run through AttributeIngester
        def file_attributes
          {}
        end
  
        def files
          file_list = [metadata_file]
          file_list << media_file if media_file
          file_list
        end

        def filename
          id.to_s.sub(/.*\//, '')
        end

        def metadata_file
          { mime_type: mime_type,
            path: id,
            filename: id.to_s.sub(/.*\//, ''),
            file_opts: {},
            use: use(filename).to_s
          }
        end

        def use(_file_name_pattern)
          :original_file
        end

        def media_file
        end

        def events
        end

      end

      class XmlReader < AbstractReader
        def initialize(id, source)
          @id = id
          @source = source
          @mime_type = 'application/xml'
          @xml = Nokogiri::XML(source).remove_namespaces!
          parse
        end
        attr_reader :xml

        def type
          :xml
        end

        def get_attributes_set(atts_const)
          begin
            att_lookups = self.class.const_get(atts_const)
          rescue
            return {}
          end
          att_lookups.inject({}) do |h, (k,v)|
            h[k] = xml.xpath(v).map(&:text)
            h
          end
        end

        # for Work metadata
        def attributes
          get_attributes_set(:WORK_ATT_LOOKUPS)
        end

        # for fileset metadata run through AttributeIngester
        def file_attributes
          get_attributes_set(:FILE_ATT_LOOKUPS)
        end
      end

      class PbcoreReader < XmlReader
        WORK_ATT_LOOKUPS = {
        }
        FILE_ATT_LOOKUPS = {
          file_format: '//instantiationStandard'
        }
        def type
          :pbcore
        end
      end
    end
  end
end
