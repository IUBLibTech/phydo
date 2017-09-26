class FileSetIndexer < Hyrax::FileSetIndexer

  def generate_solr_document
    super.tap do |solr_doc|
      solr_doc[Solrizer.solr_name('filename')] = object.file_name

      # Change indexing strategy for file_size from 32-bit ingteger to a
      # 'long' integer.
      solr_doc.delete Solrizer.solr_name(:file_size, STORED_LONG)

      solr_doc[Solrizer.solr_name(:file_size, Solrizer::Descriptor.new(:long, :stored, :indexed))] = object.file_size[0].to_i

      # Add a field for file_size in MB to use for range queries.
      solr_doc[Solrizer.solr_name(:file_size_mb, Solrizer::Descriptor.new(:long, :stored, :indexed))] = object.file_size[0].to_i / 1000000

      # FIXME: uncomment and fix this section, if needed
      # searchable_file_format = Solrizer.solr_name('file_format', :stored_searchable)
      # solr_doc[searchable_file_format] ||= []
      # solr_doc[searchable_file_format] += object.file_format.to_a

      # facetable_file_format = Solrizer.solr_name('file_format', :facetable)
      # solr_doc[facetable_file_format] ||= []
      # solr_doc[facetable_file_format] += object.file_format.to_a

      solr_doc[Solrizer.solr_name(:quality_level, :stored_searchable)] = object.quality_level
      solr_doc[Solrizer.solr_name(:original_checksum, :symbol)] = object.original_checksum

      # TODO: add accessors to the FileSet model to provide quicker, cleaner
      # access to data about the 1st ingest event.
      ingest_preservation_event = object.preservation_events.detect { |event| event.premis_event_type_abbr == 'ing' }
      if ingest_preservation_event
        Solrizer.set_field(solr_doc,
                           'ingest_date_time',
                           ingest_preservation_event.premis_event_date_time.first,
                           :stored_searchable)
      end

      # TODO: add accessors to the FileSet model to provide quicker, cleaner
      # access to data about the last fixity event.
      fixity_events = object.preservation_events.select { |event| event.premis_event_type_abbr == 'fix' }
      if (fixity_events.count)
        last_fixity_event = fixity_events.sort_by { |event| event.premis_event_date_time.first }.reverse.first
        last_fixity_date_time = last_fixity_event&.premis_event_date_time&.first

        if last_fixity_date_time
          Solrizer.set_field(solr_doc,
                             'last_fixity_date_time',
                             last_fixity_date_time,
                             :stored_searchable)
        end
      end
    end
  end
end
