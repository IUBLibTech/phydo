require 'rails_helper'

describe FileSetIndexer do

  describe '#generate_solr_document' do

    let(:sample_file_set) do
      FileSet.new.tap do |file_set|
        file_set.title = ['Test title']
        file_set.file_name = ['Test filename']
      end
    end

    subject { FileSetIndexer.new(sample_file_set) }

    it 'indexes title' do
      expect(subject.generate_solr_document['title_si']).to eq sample_file_set.title
    end
    it 'indexes filename' do
      expect(subject.generate_solr_document['filename_tesim']).to eq sample_file_set.file_name
    end
    pending 'indexes file_format'
    pending 'indexes file_size'
    pending 'indexes file_size_mb'
    pending 'indexes original_checksum'
    pending 'indexes quality_level'
  end
end
