require 'rails_helper'
require 'hyrax/ingest/batch_runner'

RSpec.describe "WGBH ingest example 3 batch" do
  # TODO: Currently the Fedora cleaning mechanism operates per each test. To speed things up
  # have Fedora only be cleaned once per context.
  before do
    @sip_paths = Dir.glob('./spec/features/wgbh_ingest/example_4/example_4_batch/139688')
    @runner = Hyrax::Ingest::BatchRunner.new(config_file_path: File.expand_path('../ingest_example_4_config.yml', __FILE__), sip_paths: @sip_paths)
    @runner.run!
  end

  # TODO: This is used more than once across examples. Move to shared examples?
  it 'ingests all of the SIPs', :clean_fedora, :large_ingest do
    expect(FileSet.all.count).to eq @sip_paths.count
  end

  it 'ingests a fixity check event with metadata', :clean_fedora, :large_ingest do

    FileSet.all.each do |file_set|
      # First grab the fixity check by selecting the one with PREMIS event type of 'fix'.
      fixity_check_event = file_set.preservation_events.detect do |event|
        event.premis_event_type.first.to_uri.to_s == "http://id.loc.gov/vocabulary/preservation/eventType/fix"
      end

      # Expect there to be a fixity check event.
      expect(fixity_check_event).to be_a Hyrax::Preservation::Event

      # Expect the fixity check date to be 2017-03-30.
      # NOTE: all FileSets ingested in this batch have the same date.
      expect(fixity_check_event.premis_event_date_time.first).to eq Date.parse('2017-03-30')

      # Expect the fixity check event to have an outcome of 'pass'.
      # NOTE: all FileSets in this batch have the same outcome.
      expect(fixity_check_event.premis_event_outcome.first).to eq "pass"
    end
  end
end
