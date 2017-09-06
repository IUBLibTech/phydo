require 'rails_helper'

describe Phydo::FileSetPresenter do
  let(:user) { User.create!(email: 'test@example.com', password: 'password') }
  let(:file_set) { fs = FileSet.new(title: ['Test label']); fs.apply_depositor_metadata(user); fs.save!; fs }
  let(:ability) { Ability.new(user) }
  let(:presenter) { described_class.new(SolrDocument.new(file_set.to_solr), ability) }
  describe '#page_title' do
    it 'returns the first title of the FileSet' do
      expect(presenter.page_title).to eq file_set.title.first
    end
  end
  describe '#link_name' do
    context 'with the ability to read the FileSet' do
      context 'with a file_name' do
        before(:each) { file_set.file_name = ['Test filename']; file_set.save! }
        it 'returns the first file_name' do
          expect(presenter.link_name).to eq file_set.file_name.first
        end
      end
      context 'without a file_name' do
        it 'returns "Unknown"' do
          expect(presenter.link_name).to eq 'Unknown'
        end
      end
    end
    context 'without the ability to read the FileSet' do
      let(:ability) { Ability.new(User.new) }
      it 'returns "File"' do
        expect(presenter.link_name).to eq 'File'
      end
    end
  end
  describe '#system_create' do
    it 'returns a date string' do
      expect(presenter.system_create).to be_a String
    end
  end
  describe '#system_modified' do
    it 'returns a date string' do
      expect(presenter.system_modified).to be_a String
    end
  end

  describe '#deaccessioned?' do
    let(:deaccession) do
      dea = Hyrax::Preservation::Event.create(premis_event_type: [Hyrax::Preservation::PremisEventType.new('dea').uri], premis_event_outcome: Array.wrap(outcome))
      dea.premis_event_related_object = file_set
      dea.save!
      dea
    end

    context 'without a deaccesion event' do
      it 'returns false' do
        expect(presenter.deaccessioned?).to eq false
      end
    end
    context 'with a failed deaccession event' do
      let(:outcome) { 'FAIL' }
      before(:each) { deaccession }

      it 'returns false' do
        expect(presenter.deaccessioned?).to eq false
      end
    end
    context 'with a successful deaccession event' do
      let(:outcome) { 'PASS' }
      before(:each) { deaccession }

      it 'returns true' do
        expect(presenter.deaccessioned?).to eq true
      end
    end
  end
end
