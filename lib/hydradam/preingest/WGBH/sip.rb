require './lib/hydradam/preingest/attribute_ingester.rb'

module HydraDAM
  module Preingest
    module WGBH
      class SIP
        def initialize(opts={})
            @pbcore_xml_file = opts[:pbcore]
            @fitx_xml_file = opts[:fits]
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
          @work_attributes = {}
          @file_set_attributes = {}
          @source_metadata = nil
          @file_sets = []
          @sources = []
          @md5sums_map = {}
          @md5events_map = {}
          @creation_events_map = {}
          @purls_map = {}
          @parts_map = {}
          @date_generated_map = {}

          filenames.each { |filename| process_file(filename) }
          postprocess
        end
        
        def filenames
          @filenames ||= Dir["#{root_dir}/*"]
        end
        
        def process_file(filename)
          file_set = { filename: filename.sub(/.*\//, '') }
          file_reader = HydraDAM::Preingest::WGBH::FileReader.new(filename)
          unless file_reader&.type.nil?
            work_ai = HydraDAM::Preingest::AttributeIngester.new(file_reader.id, file_reader.attributes, factory: resource_class)
            file_set_ai = HydraDAM::Preingest::AttributeIngester.new(file_reader.id, file_reader.file_attributes, factory: FileSet)
            if file_reader.type.in? [:pbcore, :fits]
              @work_attributes[file_reader.type] = work_ai.raw_attributes
              @file_set_attributes[file_reader.type] = file_set_ai.raw_attributes
              # MDPI value "wins" over manifest value
              @md5sums_map.merge!(file_reader.reader.md5sums_map) if file_reader.type == :mdpi
              @md5events_map = array_merge(@md5events_map, file_reader.reader.md5events_map) if file_reader.type == :mdpi
              @creation_events_map = file_reader.reader.creation_events_map if file_reader.type == :mdpi
              @parts_map = file_reader.reader.parts_map if file_reader.type == :mdpi
              @date_generated_map = file_reader.reader.date_generated_map if file_reader.type == :mdpi
              file_set[:files] = file_reader.files
            elsif file_reader.type.in? [:purl, :md5]
              @purls_map = file_reader.reader.purls_map if file_reader.type == :purl
              @md5sums_map = file_reader.reader.md5sums_map.merge(@md5sums_map) if file_reader.type == :md5
              @md5events_map = array_merge(@md5events_map, file_reader.reader.md5events_map) if file_reader.type == :md5
              file_set[:files] = file_reader.files
            else
              file_set[:attributes] = file_set_ai.raw_attributes
              file_set[:files] = file_reader.files
            end
            file_set[:events] = file_reader.events if file_reader.events
          end
          @file_sets << file_set if file_set.present?
        end
        
         def array_merge(h1, h2)
          h = {}
          h1 ||= {}
          h2 ||= {}
          keys = h1.keys.sort | h2.keys.sort
          keys.each do |k|
            h[k] = Array.wrap(h1[k]) + Array.wrap(h2[k])
          end
          h
        end
        
        def postprocess
          @file_sets.each do |file_set|
            if file_set[:files].present?
              file_set[:files].each do |file|
                if file[:filename]
                  file[:md5sum] = @md5sums_map[file[:filename]] if @md5sums_map[file[:filename]]
                  file[:purl] = @purls_map[file[:filename]] if @purls_map[file[:filename]]
                end
              end
              # FIXME: media file wins, if available?
              file_set[:filename] = file_set[:files].last[:filename]
              # FIXME: this bypasses attribute ingester...
              file_set[:attributes][:md5_checksum] = Array.wrap(file_set[:files].last[:md5sum]) if file_set[:attributes].present?
            end
            if @md5events_map && @md5events_map[file_set[:filename]]
              file_set[:events] ||= []
              file_set[:events] += @md5events_map[file_set[:filename]]
            end
            if @creation_events_map && @creation_events_map[file_set[:filename]]
              file_set[:events] ||= []
              file_set[:events] << @creation_events_map[file_set[:filename]]
            end
            if @parts_map && @parts_map[file_set[:filename]]
              file_set[:attributes][:part] = @parts_map[file_set[:filename]]
            end
            if @date_generated_map && @date_generated_map[file_set[:filename]]
              file_set[:attributes][:date_generated] = @date_generated_map[file_set[:filename]]
            end
          end
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

        def md5sums_map_to_events(mapping, agent: 'mailto@mdpi.iu.edu')
          results = {}
          mapping.each do |filename, checksum|
            atts = {}
            atts[:premis_event_type] = ['mes']
            atts[:premis_agent] = [agent]
            atts[:premis_event_date_time] = Array.wrap(DateTime.parse(File.mtime(id).to_s).to_s)
            atts[:premis_event_detail] = ['Program used: python, hashlib.sha256()'] #FIXME: vary
            atts[:premis_event_outcome] = [checksum]
            results[filename] = { attributes: atts }
          end
          results
        end

        def creation_dates_to_events(mapping, agent: 'mailto@mdpi.iu.edu')
          results = {}
          mapping.each do |filename, date|
            atts = {}
            atts[:premis_event_type] = ['cre']
            atts[:premis_agent] = [agent]
            atts[:premis_event_date_time] = Array.wrap(date)
            atts[:premis_event_detail] = ['File created']
            results[filename] = { attributes: atts }
          end
          results
        end

      end
