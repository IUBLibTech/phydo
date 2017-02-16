require 'rails_helper'

describe FileSet do
  describe '#to_solr' do
    it 'runs without error' do
      expect { described_class.new.to_solr }.not_to raise_error
    end
  end
end  
