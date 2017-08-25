require 'rails_helper'
require 'hyrax/ingest/batch_runner'

RSpec.describe "WGBH ingest example 3 batch" do

  let(:sip_paths) { Dir.glob('./spec/features/wgbh_ingest/example_3/example_3_batch/*') }
  let(:num_sips) { sip_paths.count }

  before do
    @runner = Hyrax::Ingest::BatchRunner.new(config_file_path: File.expand_path('../ingest_example_3_config.yml', __FILE__), sip_paths: sip_paths)
    @runner.run!
  end

  let(:file_sets) { FileSet.all }

  it 'ingests all of the SIPs', :clean_fedora, :large_ingest do
    expect(file_sets.count).to eq num_sips
  end
end
