require 'rails_helper'

RSpec.describe FixityCheckJob do

  let(:user) { User.first_or_create!(email: 'test@example.com', password: 'password') }

  let(:file_set_attrs) { [ { id: '123', title: 'Title 1' }, { id: '456', title: 'Title 2' } ] }

  let(:premis_event_attrs) {
    [ { premis_event_type: Hyrax::Preservation::PremisEventType.find_by_abbr('mes').uri, premis_event_outcome: '6763320f999439f96961fa3209133b9b', premis_event_related_object_id: '123' }, { premis_event_type: Hyrax::Preservation::PremisEventType.find_by_abbr('mes').uri, premis_event_outcome: '6763320f999439f96961fa3209133b9b', premis_event_related_object_id: '123' }, { premis_event_type: Hyrax::Preservation::PremisEventType.find_by_abbr('mes').uri, premis_event_outcome: '885ed0fb6cf8e55cac6f5b548730f879', premis_event_related_object_id: '456' }, { premis_event_type: Hyrax::Preservation::PremisEventType.find_by_abbr('mes').uri, premis_event_outcome: '885ed0fb6cf8e55cac6f5b548730NOPE', premis_event_related_object_id: '456' } ]
  }

  describe 'when running the fixity check job', :clean_fedora do
    before do
      file_set_attrs.each do |fsa|
        FileSet.new.tap do |fs|
          fs.id = fsa[:id]
          fs.title << fsa[:title]
          fs.save!
        end
      end

      premis_event_attrs.each do |pea|
        Hyrax::Preservation::Event.new.tap do |pe|
          pe.premis_event_type << pea[:premis_event_type]
          pe.premis_event_outcome << pea[:premis_event_outcome]
          pe.premis_event_related_object_id = pea[:premis_event_related_object_id]
          pe.premis_event_date_time << DateTime.now
          pe.save!
        end
      end

      described_class.new( { user: user, ids: %w(123 456) } ).run
    end

    it 'creates passing fix event for FileSet if last 2 mes events match' do
      expect( Hyrax::Preservation::Event.search_with_conditions(hasEventRelatedObject_ssim: "123", premis_event_type_ssim: 'fix').first["premis_event_outcome_tesim"] ).to eq(["pass"])
    end

    it 'creates failing fix event for FileSet if last 2 mes events do not match' do
      expect( Hyrax::Preservation::Event.search_with_conditions(hasEventRelatedObject_ssim: "456", premis_event_type_ssim: 'fix').first["premis_event_outcome_tesim"] ).to eq(["fail"])
    end
  end
end