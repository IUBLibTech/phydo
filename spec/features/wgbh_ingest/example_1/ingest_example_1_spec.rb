require 'rails_helper'
require 'hyrax/ingest/runner'

RSpec.describe "WGBH ingest example 1" do

  before do
    @runner = Hyrax::Ingest::Runner.new(config_file_path: File.expand_path('../ingest_example_1_config.yml', __FILE__), sip_path: File.expand_path('../example_1_files', __FILE__))
    @runner.run!
  end

  let(:file_set) { FileSet.first }

  describe 'assigning metadata', :clean_fedora do

    it 'fetches metadata from the SIP and puts it in the correct properties' do
      expect(file_set.file_format).to eq ["Quicktime"]
      expect(file_set.codec_name).to eq ["AVdn"]
      expect(file_set.format_duration).to eq ['1062395']
      expect(file_set.file_name).to eq ["STL17C_1.mov"]
      expect(file_set.format_file_size).to eq "19626182203"
      expect(file_set.bit_rate).to eq ["147788212"]

      # TODO: Ask Rebecca if grabbing the first value from the first audio
      # track of a <video> FITS element is what we want.
      expect(file_set.format_sample_rate).to eq ['48000']

      expect(file_set.video_width).to eq ["1920 pixels"]
      expect(file_set.video_height).to eq ["1080 pixels"]
      expect(file_set.md5_checksum).to eq ["28e635e58033c26be40460e67625c549"]
      expect(file_set.file_path).to eq ["/Volumes/Public_Archives/Antiques_Roadshow/Antiques_Roadshow_To_Archives/03_St_Louis_Media/Kipro_files_2/STL17C_1.mov"]
      expect(file_set.barcode).to eq ["372304"]
    end
  end
end
