require 'rails_helper'
require 'hyrax/preservation'

describe SolrDocument do
  let!(:document) { described_class.new(file_set.to_solr) }
  let!(:file_set) { FactoryGirl.create(:file_set, user: FactoryGirl.create(:user)) }

  describe "associated preservation message digest events", :clean_fedora do
    let(:premis_event_type) { [ Hyrax::Preservation::PremisEventType.find_by_abbr('mes').uri ] }

    let!(:current_mes) { FactoryGirl.create(:preservation_event, premis_event_related_object: file_set, premis_event_type: premis_event_type, premis_event_date_time: [ DateTime.parse('2016-02-01T04:05:06+07:00') ], premis_event_outcome: [ '63ab6f1c03a33f2b4c2148eb6bb8c425' ] ) }

    let!(:previous_mes) { FactoryGirl.create(:preservation_event, premis_event_related_object: file_set, premis_event_type: premis_event_type, premis_event_date_time: [ DateTime.parse('2015-02-01T04:05:06+07:00') ], premis_event_outcome: [ '63ab6f1c03a33f2b4c2148eb6bb8c425' ] ) }

    describe '.mes_events' do
      it 'should find all associated mes events' do
        expect(document.mes_events.count).to eq(2)
      end
    end

    describe '.current_mes_event' do
      it 'should return the current mes event' do
        expect(current_mes.id).to eq(document.current_mes_event.id)
      end
    end

    describe '.previous_mes_event' do
      it 'should return the previous mes event' do
        expect(previous_mes.id).to eq(document.previous_mes_event.id)
      end
    end

    context 'with clean message digest events' do
      describe '.current_mes_event_changed?' do
        it 'should return false' do
          expect(document.current_mes_event_changed?).to eq(false)
        end
      end
    end

    context 'with an unclean(!) current message digest event' do
      let!(:dirty_mes) { FactoryGirl.create(:preservation_event, premis_event_related_object: file_set, premis_event_type: premis_event_type, premis_event_date_time: [ DateTime.parse('2017-02-01T04:05:06+07:00') ], premis_event_outcome: [ '885ed0fb6cf8e55cac6f5b548730f879' ] ) }

      describe '.current_mes_event_changed?' do
        it 'should return true' do
          expect(document.current_mes_event_changed?).to eq(true)
        end
      end
    end
  end
end