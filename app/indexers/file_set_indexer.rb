class FileSetIndexer < Hyrax::FileSetIndexer

  def generate_solr_document
    super.tap do |solr_doc|
      solr_doc[Solrizer.solr_name(:title)] = unless object.title.empty?
        object.title
      else
        object.file_name
      end

      solr_doc[Solrizer.solr_name(:file_name)] = object.file_name
      solr_doc[Solrizer.solr_name(:date_generated, Solrizer::Descriptor.new(:date, :stored, :indexed))] = Time.at object.date_generated.first.to_i

      # Change indexing strategy for file_size from 32-bit ingteger to a
      # 'long' integer.
      solr_doc.delete Solrizer.solr_name(:file_size, STORED_LONG)
      file_size = object.format_file_size || object.file_size[0]
      if file_size
        solr_doc[Solrizer.solr_name(:file_size, Solrizer::Descriptor.new(:long, :stored, :indexed))] = file_size.to_i if file_size

        # Add a field for file_size in MB to use for range queries.
        solr_doc[Solrizer.solr_name(:file_size_mb, Solrizer::Descriptor.new(:long, :stored, :indexed))] = object.format_file_size.to_i / 1000000
      end

      # FIXME: uncomment and fix this section, if needed
      # searchable_file_format = Solrizer.solr_name('file_format', :stored_searchable)
      # solr_doc[searchable_file_format] ||= []
      # solr_doc[searchable_file_format] += object.file_format.to_a

      # facetable_file_format = Solrizer.solr_name('file_format', :facetable)
      # solr_doc[facetable_file_format] ||= []
      # solr_doc[facetable_file_format] += object.file_format.to_a

      # solr_doc[Solrizer.solr_name(:quality_level, :stored_searchable)] = object.quality_level
      # solr_doc[Solrizer.solr_name(:original_checksum, :symbol)] = object.original_checksum

      # TODO: add accessors to the FileSet model to provide quicker, cleaner
      # access to data about the 1st ingest event.
      ingest_preservation_event = object.preservation_events.detect { |event| event.premis_event_type_abbr == 'ing' }
      if ingest_preservation_event
        Solrizer.set_field(solr_doc,
                           'ingest_date_time',
                           ingest_preservation_event.premis_event_date_time.first,
                           :stored_searchable)
      end

      unless object.fixity_events.empty?
        Solrizer.set_field(solr_doc,
                           'last_fixity_date_time',
                           object.fixity_events.last.premis_event_date_time.first,
                           :stored_searchable)
      end
    end
  end

  # Directly set file_format instead of deriving from mime type.
  def file_format
    object.file_format.to_a
  end
end
