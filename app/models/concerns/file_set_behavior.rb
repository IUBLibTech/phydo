module Concerns
  module FileSetBehavior
    extend ActiveSupport::Concern

    included do

      # FIXME: maintain directly_contains_one relations?
      # TODO: replace bogus predicate with legit one.
      # directly_contains_one :ffprobe, through: :files, type: ::RDF::URI('http://example.org/TODO-replace-with-actual-predicate'), class_name: 'XMLFile'
      # FIXME:  HasEXIF, HasFITS were not in use; retain these?
      # directly_contains_one :exif, through: :files, type: ::RDF::URI('http://example.org/TODO-replace-with-actual-predicate'), class_name: 'XMLFile'
      # directly_contains_one :fits, through: :files, type: ::RDF::URI('http://example.org/TODO-replace-with-actual-predicate'), class_name: 'XMLFile'

      property :date_generated, predicate: RDF::Vocab::EBUCore.dateCreated do |index|
         index.as :stored_searchable, :facetable, :stored_sortable
         index.type :date
      end

      property :file_format, predicate: RDF::Vocab::EBUCore.hasFileFormat do |index|
         index.as :stored_sortable, :facetable
      end

      property :file_format_long_name, predicate: RDF::Vocab::PREMIS.hasFormatName do |index|
         index.as :stored_searchable, :stored_sortable, :facetable
      end

      property :file_name, predicate: RDF::Vocab::EBUCore.filename do |index|
         index.as :stored_searchable, :sortable
      end

      property :format_file_size, predicate: RDF::Vocab::EBUCore.fileSize, multiple: false do |index|
        index.as :stored_searchable, :sortable
      end

      property :identifier, predicate: RDF::Vocab::EBUCore.identifier do |index|
        index.as :symbol
      end

      # TODO use correct predicates for Unit of Origin properties
      # property :unit_of_origin, predicate: RDF::Vocab::EBUCore.description do |index|
      property :unit_of_origin, predicate: RDF::Vocab::EBUCore.comments do |index|
         index.as :stored_searchable, :facetable, :stored_sortable
      end

      property :part, predicate: RDF::Vocab::EBUCore.partNumber do |index|
        index.as :facetable, :stored_sortable
      end

      property :format_sample_rate, predicate: RDF::Vocab::EBUCore.sampleRate do |index|
        index.as :stored_searchable, :facetable, :stored_sortable
      end

      property :video_width, predicate: RDF::Vocab::EBUCore.width do |index|
        index.as :stored_searchable, :facetable, :stored_sortable
      end

      property :video_height, predicate: RDF::Vocab::EBUCore.height do |index|
        index.as :stored_searchable, :facetable, :stored_sortable
      end

      property :md5_checksum, predicate: RDF::Vocab::NFO.hashValue do |index|
         index.as :symbol
      end
      # FIXME: not sure we want to duplicate use of this predicate?
      # property :original_checksum, predicate: RDF::Vocab::EBUCore.hashValue do |index|
        # index.as :stored_searchable
      # end

      property :title, predicate: RDF::Vocab::EBUCore.title do |index|
        index.as :stored_searchable, :sortable, :facetable
      end

      property :quality_level, predicate: RDF::Vocab::EBUCore.encodingLevel, multiple: false do |index|
        index.as :stored_searchable, :facetable
      end
      property :audio_codec_type, predicate: RDF::Vocab::EBUCore.hasAudioFormat do |index|
        index.as :stored_searchable, :facetable
      end
      property :video_codec_type, predicate: RDF::Vocab::EBUCore.hasVideoFormat do |index|
        index.as :stored_searchable, :facetable
      end
      property :codec_name, predicate: RDF::Vocab::EBUCore.hasCodec do |index|
        index.as :stored_searchable, :facetable
      end
      property :codec_long_name, predicate: RDF::Vocab::EBUCore.codecName do |index|
        index.as :stored_searchable, :facetable
      end
      property :format_duration, predicate: RDF::Vocab::EBUCore.duration do |index|
        index.as :stored_searchable, :sortable, :facetable
      end
      property :bit_rate, predicate: RDF::Vocab::EBUCore.bitRate do |index|
        index.as :stored_searchable, :sortable, :facetable
      end
      property :file_path, predicate: RDF::Vocab::EBUCore.locator do |index|
        index.as :stored_searchable, :symbol, :sortable
      end

      property :file_path, predicate: RDF::Vocab::EBUCore.locator do |index|
        index.as :sortable, :facetable
      end

      property :barcode, predicate: RDF::Vocab::EBUCore.storageDefinition do |index|
        index.as :symbol
      end
    end

    # Returns a list of associated Preservation::Event objects that have
    # PREMIS event type of 'fix', and are sorted by PREMIS event date.
    # TODO: move to Hyrax-preservation gem as a behavior that gets added to
    # FileSet.
    def fixity_events
      preservation_events.select do |event|
        premis_event_type_uri = event.premis_event_type.first.id
        Hyrax::Preservation::PremisEventType.find_by_uri(premis_event_type_uri).abbr == 'fix'
      end.sort do |fixity_event|
        fixity_event.premis_event_date_time.first
      end
    end
  end
end
