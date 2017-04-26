# frozen_string_literal: true
class SearchBuilder < Blacklight::SearchBuilder
  include Blacklight::Solr::SearchBuilderBehavior
  include BlacklightRangeLimit::RangeLimitBuilder
  include BlacklightAdvancedSearch::AdvancedSearchBuilder
  # TODO: Where do these come from, and why are we adding them here?
  self.default_processor_chain += [:add_advanced_parse_q_to_solr, :add_advanced_search_to_solr, :apply_ingest_date_time_filter]
  include Hydra::AccessControlsEnforcement
  include Hyrax::SearchFilters


  def filter_models(solr_parameters)
    solr_parameters[:fq] ||= []
    solr_parameters[:fq] << '(' + (work_clauses + collection_clauses + file_set_clauses).join(' OR ') + ')'
  end
  
  def file_set_clauses
    [ActiveFedora::SolrQueryBuilder.construct_query_for_rel(has_model: ::FileSet.to_rdf_representation)]
  end

  def work_clauses
    [ActiveFedora::SolrQueryBuilder.construct_query_for_rel(has_model: ::Work.to_rdf_representation)]
  end

  def collection_clauses
    [ActiveFedora::SolrQueryBuilder.construct_query_for_rel(has_model: ::Collection.to_rdf_representation)]
  end


  def apply_ingest_date_time_filter(solr_params)
    if ingest_date_time_filter
      solr_params[:fq] ||= []
      solr_params[:fq] << ingest_date_time_filter
    end
    solr_params
  end

  private

    def ingest_date_time_filter
      @ingest_date_time_filter ||= begin
        if ingest_date_time_before || ingest_date_time_after
          range = "#{ingest_date_time_after || '*'} TO #{ingest_date_time_before || '*'}"
          "ingest_date_time_dtsim:[#{range}]"
        end
      end
    end

    # Returns the 'before' date time formatted for a Solr query.
    def ingest_date_time_before
      @ingest_date_time_before ||= formatted_ingest_date_time(blacklight_params['ingest_date_time_before'])
    end

    # Returns the 'after' date time formatted for a Solr query.
    def ingest_date_time_after
      @ingest_date_time_after ||= formatted_ingest_date_time(blacklight_params['ingest_date_time_after'])
    end

    # Converts an unformatted date (as passed in via URL) to a date formatted
    # for a Solr query.
    def formatted_ingest_date_time(unformatted_date)
      DateTime.parse(unformatted_date.to_s).utc.strftime("%Y-%m-%dT%H:%M:%SZ")
    rescue ArgumentError => e
      nil
    end
end
