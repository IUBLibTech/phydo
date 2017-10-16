module Phydo
  class CatalogSearchBuilder < Hyrax::CatalogSearchBuilder

    self.default_processor_chain += [
      :apply_last_fixity_date_time_filter,
      :apply_barcode_filter
    ]

    def models
      super + [::FileSet]
    end

    def apply_last_fixity_date_time_filter(solr_params)
      if last_fixity_date_time_filter
        solr_params[:fq] ||= []
        solr_params[:fq] << last_fixity_date_time_filter
      end
      solr_params
    end

    def apply_barcode_filter(solr_params)
      if barcode_filter
        solr_params[:fq] ||= []
        solr_params[:fq] << barcode_filter
      end
      solr_params
    end

    private

      # Returns a date/time range for a Solr query for the 'after' and 'before'
      # URL params.
      def last_fixity_date_time_filter
        @last_fixity_date_time_filter ||= begin
          if last_fixity_date_time_before || last_fixity_date_time_after
            range = "#{last_fixity_date_time_after || '*'} TO #{last_fixity_date_time_before || '*'}"
            "last_fixity_date_time_dtsim:[#{range}]"
          end
        end
      end

      # Returns 'after' date time of last fixity check, formatted for a Solr query.
      def last_fixity_date_time_after
        @last_fixity_date_time_after ||= formatted_last_fixity_date_time(blacklight_params['last_fixity_date_time_after'])
      end

      # Returns 'after' date time of last fixity check, formatted for a Solr query.
      def last_fixity_date_time_before
        @last_fixity_date_time_before ||= formatted_last_fixity_date_time(blacklight_params['last_fixity_date_time_before'])
      end

      # Converts an unformatted date (as passed in via URL) to a date formatted
      # for a Solr query.
      def formatted_last_fixity_date_time(unformatted_date)
        DateTime.parse(unformatted_date.to_s).utc.strftime("%Y-%m-%dT%H:%M:%SZ")
      rescue ArgumentError => e
        nil
      end

      def barcode_filter
        @barcode_filter ||=
          unless blacklight_params['barcode'].blank?
            'barcode_ssim:' + blacklight_params['barcode']
          end
      end
  end
end
