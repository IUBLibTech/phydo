require 'rails_helper'

describe CurationConcerns::FilePresenter do
  let(:user) { User.create!(email: 'test@example.com', password: 'password') }
  let(:file_set) { fs = FileSet.new(label: 'Test label'); fs.apply_depositor_metadata(user); fs.save!; fs }
  let(:file) { f = Hydra::PCDM::File.new }
  let(:ability) { Ability.new(user) }
  let(:presenter) { described_class.new(file, ability) }

  describe '#thumbnail' do
    it 'returns a substring of the first /#use/ model_type uri' do
      expect(presenter.thumbnail).to match file.model_type.select { |t| t.to_uri.to_s.match /use#/ }.first.to_s
    end
  end
  describe '#filename' do
    it 'returns the first file_name value' do
      file.file_name = ['filename1.txt']
      expect(presenter.filename).to eq file.file_name.first.to_s
    end
  end
  describe '#date_uploaded' do
    it 'returns the first date_created value' do
      file.date_created = [Time.now]
      expect(presenter.date_uploaded).to eq file.date_created.first
    end
  end
  describe '#uri' do
    it 'returns the file uri' do
      file.uri = 'file:///test/uri'
      expect(presenter.uri).to eq file.uri.to_s
    end
  end
end  
