module Phydo
  class FixityCheckReport
    attr_accessor :max_date

    def initialize(max_date: nil)
      @max_date = max_date.to_i
    end

    def query
      results = []
      FileSet.search_in_batches({}) do |file_set_batch|
        file_set_batch.each do |file_set|
          fixity_check = Hyrax::Preservation::Event.search_with_conditions(
            { hasEventRelatedObject_ssim: file_set['id'], premis_event_type_ssim: 'fix' },
            sort: 'premis_event_date_time_integer_ltsi desc', rows: 1
          ).last
          if fixity_check.nil? || max_date.zero? || fixity_check['premis_event_date_time_integer_ltsi'].to_i < max_date
            results << row_for(file_set, fixity_check)
          end
        end
      end
      results
    end

    def formatted_results
      [I18n.t('fixity_check_report.headers')] + query.sort_by(&:last)
    end

    private

      def row_for(file_set, preservation_event)
        preservation_event ||= {}
        [file_set['file_name_tesim']&.first.to_s,
         file_set['title_tesim']&.first.to_s,
         file_set['file_path_tesim']&.first.to_s,
         preservation_event['premis_event_date_time_integer_ltsi'].to_i]
      end
  end
end
