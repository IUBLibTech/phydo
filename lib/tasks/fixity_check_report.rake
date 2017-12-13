namespace :phydo do
  desc "E-mail a fixity check report"
  task fixity_check_report: :environment do
    max_date = ENV['MAX_DATE']

    user = User.find_by_user_key( ENV['USER'] ) if ENV['USER']
    user = User.first unless user
    abort "User unspecified or not found" unless user
  
    logger = Logger.new(STDOUT)
    logger.info "setting max date: #{max_date || 'N/A'}"
    logger.info "reporting to: #{user.user_key} (override with USER=foo)"
    begin
      require Rails.root.join('lib', 'phydo', 'fixity_check_report.rb')
      results = Phydo::FixityCheckReport.new(max_date: max_date).formatted_results
      tempfile = Tempfile.new(['phydo_fixity_check_report', '.csv'])
      CSV.open(tempfile.path, 'w') do |csv|
        results.each { |row| csv << row }
      end
      mail = FixityCheckReportMailer.new.report_email(user)
      mail.attachments["fixity_check_report_#{Time.now.strftime('%Y-%m-%d')
}.csv"] = File.read(tempfile.path)
      mail.deliver
      logger.info "Completed mail delivery"
    rescue => e
      logger.error "Error: #{e.message}"
      logger.error e.backtrace
      abort "Error encountered"
    ensure
      tempfile&.close
      tempfile&.unlink
    end
  end
end
