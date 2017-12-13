require "rails_helper"

RSpec.describe FixityCheckReportMailer, type: :mailer do
  let(:user) { FactoryGirl.create :user }
  let(:report_mailer) { described_class.new }

  describe "#report_email" do
    it "returns a mail message" do
      expect(report_mailer.report_email(user)).to be_a Mail::Message     
    end
  end
end
