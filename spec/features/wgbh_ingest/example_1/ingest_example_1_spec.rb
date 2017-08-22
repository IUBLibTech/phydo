require 'rails_helper'
require 'hyrax/ingest/runner'

RSpec.describe "WGBH ingest example 1" do

  before do
    @runner = Hyrax::Ingest::Runner.new(config_file_path: File.expand_path('../ingest_example_1_config.yml', __FILE__), source_files_path: File.expand_path('../example_1_files', __FILE__))
    @runner.run!
  end

  let(:file_set) { FileSet.first }

  describe 'assigning metadata', :clean_fedora do
    it "fetches the format from PBCore XML" do
      expect(file_set.file_format_long_name).to eq ["format= Quicktime "]
    end

    it 'fetches the width and height from FITS xml' do
      expect(file_set.video_width).to eq ["1920 pixels"]
      expect(file_set.video_height).to eq ["1080 pixels"]
    end
  end
end
