require 'rails_helper'

describe Hyrax::EventPresenter do
  let!(:user) { User.create!(email: 'test@example.com', password: 'password') }
  let!(:file_set) { fs = FileSet.new(label: 'Test label'); fs.apply_depositor_metadata(user); fs.save!; fs }
  let!(:event) { Hyrax::Preservation::Event.create(premis_event_related_object_id: file_set.id,
                                            premis_event_outcome: ['SUCCESS'],
                                            premis_agent: [::RDF::URI.new("mailto:#{user.email}")],
                                            premis_event_date_time: [Time.now],
                                            premis_event_type: [Hyrax::Preservation::PremisEventType.new('ing').uri]) }

  let!(:solr_event) { Hyrax::Preservation::Event.search_with_conditions(hasEventRelatedObject_ssim: file_set.id).first }
  let!(:ability) { Ability.new(user) }
  let!(:presenter) { described_class.new(solr_event, ability) }

  describe '#type_display' do
    it 'returns full text for PREMIS event type' do
      expect(presenter.type_display).to match /^PREMIS/
    end
  end

  describe "#type_link" do
    it 'returns a link to the related object\'s events, filtered by event type' do
      expect(presenter.type_link).to eq Hyrax::Preservation::Engine.routes.url_helpers.events_path(related_object: presenter.related_object, 'premis_event_type[]' => presenter.type_code)
    end
  end

  describe '#event_link' do
    it 'returns link to event' do
      expect(presenter.event_link).to eq Hyrax::Preservation::Engine.routes.url_helpers.event_path(event.id)
    end
  end

  describe "#type_code" do
    it 'returns the 3-letter event type code' do
      expect(presenter.type_code).to eq 'ing'
    end
  end

  describe "#related_object" do
    it 'returns the related object id' do
      expect(presenter.related_object).to eq file_set.id
    end
  end

  describe '#outcome' do
    it 'returns outcome string' do
      expect(presenter.outcome).to eq 'SUCCESS'
    end
  end

  describe '#date' do
    it 'returns a valid date' do
      expect { DateTime.parse(presenter.date) }.not_to raise_error
    end
  end

  describe '#agent' do
    it 'returns email portion of mailto:' do
      expect(presenter.agent).to eq user.email
    end
  end
end  
