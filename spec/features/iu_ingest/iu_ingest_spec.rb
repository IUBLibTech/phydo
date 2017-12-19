require 'rails_helper'
require 'hyrax/ingest/runner'

RSpec.describe 'Ingest IU YAML' do

  skip "Not using ingest gem currently" do
  before do
    @runner = Hyrax::Ingest::Runner.new(config_file_path: File.expand_path('spec/features/iu_ingest/iu_ingest.yaml'),
                                        source_files_path: File.expand_path('spec/fixtures/iu_ingest'))
  end

  let(:run_ingest) { @runner.run! }
  let(:results) { run_ingest }
  let(:work) { results.first }

  context 'using wells.yml' do
    it 'should ingest one work' do
      expect(results.count).to eq 1
      expect(results.first).to be_a Work
    end

    it 'should ingest work metadata' do
      expect(work.title).to eq ['Wells Documentary, Vision of Herman B Wells']
    end

    it 'should ingest many file sets' do
      expect(work.files.count).to gt 0
    end
  end

  end
end
