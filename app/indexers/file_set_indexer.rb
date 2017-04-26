class FileSetIndexer < Hyrax::FileSetIndexer

  def generate_solr_document
    super.tap do |solr_doc|
      solr_doc[Solrizer.solr_name(:title, :sortable)] = object.title
      solr_doc[Solrizer.solr_name('filename')] = object.file_name

      # Change indexing strategy for file_size from 32-bit ingteger to a
      # 'long' integer.
      solr_doc.delete Solrizer.solr_name(:file_size, STORED_INTEGER)
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

      ingest_preservation_event = object.preservation_events.detect { |event| event.premis_event_type_abbr == 'ing' }
      if ingest_preservation_event
        Solrizer.set_field(solr_doc,
                           'ingest_date_time',
                           ingest_preservation_event.premis_event_date_time.first,
                           :stored_searchable)
      end
    end
  end
end
