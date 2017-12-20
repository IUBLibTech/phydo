require 'rails_helper'
require Rails.root.join('lib', 'phydo', 'fixity_check_report.rb') # FIXME: improve include config to deprecate this

RSpec.describe Phydo::FixityCheckReport do
  let(:max_date) { sample_date }
  let(:sample_date) { '19851025' }
  let(:old_date) { Date.new(1955, 10, 25) }
  let(:new_date) { Date.new(2015, 10, 25) }
  let(:report) { described_class.new(max_date: max_date) }
  let(:object_without_check) { FactoryGirl.create(:file_set, file_name: ['without_check.txt']) }
  let(:object_with_new_check) do
    file_set = FactoryGirl.create(:file_set, file_name: ['with_new_check.txt'])
    FactoryGirl.create(
      :preservation_event,
      premis_event_related_object: file_set,
      premis_event_type: [Hyrax::Preservation::PremisEventType.new('fix').uri],
      premis_event_date_time: [new_date]
    )
    file_set
  end
  let(:object_with_old_check) do
    file_set = FactoryGirl.create(:file_set, file_name: ['with_old_check.txt'])
    FactoryGirl.create(
      :preservation_event,
      premis_event_related_object: file_set,
      premis_event_type: [Hyrax::Preservation::PremisEventType.new('fix').uri],
      premis_event_date_time: [old_date]
    )
    file_set
  end

  describe "#max_date" do
    it "returns @max_date as an Integer" do
      expect(report.max_date).to eq sample_date.to_i
    end
  end

  describe "#query", clean_fedora: true do
    it 'returns an array' do
      expect(report.query).to be_a Array
    end
    it 'includes item before the max_date' do
      object_with_old_check
      expect(report.query).not_to be_empty
    end
    it 'excludes an item after the max_date' do
      object_with_new_check
      expect(report.query).to be_empty
    end
    it 'includes an item with no fixity check date' do
      object_without_check
      expect(report.query).not_to be_empty
    end
  end

  describe "#formatted_results" do
    it 'includes a header row' do
      expect(report.formatted_results.first).to eq I18n.t('fixity_check_report.headers')
    end
  end
end
