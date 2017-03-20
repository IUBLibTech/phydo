require 'rails_helper'

describe FileSet do
  describe '#to_solr' do
    it 'runs without error' do
      expect { described_class.new.to_solr }.not_to raise_error
    end
  end

  describe 'factory' do
    context 'when building a FileSet' do
      let(:file_set) { build(:file_set) }

      it 'returns an FileSet instance' do
        expect(file_set).to be_a FileSet
      end

      it 'is not saved' do
        expect(file_set.persisted?).to be false
      end
    end
  end
end
