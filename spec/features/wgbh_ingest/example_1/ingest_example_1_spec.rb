require 'rails_helper'
require 'hyrax/ingest/runner'

RSpec.describe "WGBH ingest example 1" do

  before do
    @runner = Hyrax::Ingest::Runner.new(config_file_path: File.expand_path('../ingest_example_1_config.yml', __FILE__), source_files_path: File.expand_path('../example_1_files', __FILE__))
    @runner.run!
  end

  let(:file_set) { FileSet.first }

  describe 'assigning metadata', :clean_fedora do

    it 'fetches metadata from the SIP and puts it in the correct properties' do
      # expect(file_set.date_generated).to eq ['ASK REBECCA']
      expect(file_set.file_format).to eq ["Quicktime"]
      # expect(file_set.file_format_long_name).to eq ["format= Quicktime "]
      # expect(file_set.codec_name).to eq []
      # expect(file_set.file_name).to eq []
      # expect(file_set.format_file_size).to eq []
      # expect(file_set.identifier).to eq []
      # expect(file_set.part).to eq []
      # expect(file_set.format_sample_rate).to eq []
      expect(file_set.video_width).to eq ["1920 pixels"]
      expect(file_set.video_height).to eq ["1080 pixels"]
      # expect(file_set.md5_checksum).to eq []
      # expect(file_set.file_path).to eq []
      # expect(file_set.).to eq []
      # expect(file_set.).to eq []
    end
  end
end
