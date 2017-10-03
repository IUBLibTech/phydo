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

  describe '#type' do
    it 'returns PREMIS event type' do
      expect(presenter.type).to match /^PREMIS/
    end
  end
  describe '#link' do
    it 'returns link to event' do
      expect(presenter.link).to eq Hyrax::Preservation::Engine.routes.url_helpers.event_path(event.id)
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
