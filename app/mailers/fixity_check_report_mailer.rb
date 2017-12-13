class FixityCheckReportMailer < ApplicationMailer
  def report_email(user)
    email_with_name = %("#{user.name}" <#{user.email}>)
    mail(to: email_with_name, subject: I18n.t('fixity_check_report.subject'), template_path: 'fixity_check_report_mailer', template_name: 'report_email')
  end
end
