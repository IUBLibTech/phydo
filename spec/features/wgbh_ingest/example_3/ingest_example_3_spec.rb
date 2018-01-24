require 'rails_helper'
require 'hyrax/ingest/batch_runner'

RSpec.describe "WGBH ingest example 3 batch" do
  # TODO: Currently the Fedora cleaning mechanism operates per each test. To speed things up
  # have Fedora only be cleaned once per context.
  before do
    @sip_paths = Dir.glob('./spec/features/wgbh_ingest/example_3/example_3_batch/*')
    @runner = Hyrax::Ingest::BatchRunner.new(config_file_path: File.expand_path('../ingest_example_3_config.yml', __FILE__), sip_paths: @sip_paths)
    @runner.run!
  end

  it 'ingests all of the SIPs', :clean_fedora, :large_ingest do
    expect(FileSet.all.count).to eq @sip_paths.count
  end

  # TODO: Lots of expectations happening in this example. Better way?
  it 'ingests 2 preservation events: one for ingest, and one for a fixity check, both having PREMIS agent as mailto:admin@example.org', :clean_fedora, :large_ingest do
    FileSet.all.each do |file_set|
      # Expect exactly 2 preservation events.
      expect(file_set.preservation_events.count).to eq 2

      # Grab all events that represent a fixity check (there should noly be 1 per FileSet).
      fixity_check_events = file_set.preservation_events.select do |event|
        event.premis_event_type.first.to_uri.to_s == 'http://id.loc.gov/vocabulary/preservation/eventType/fix'
      end

      # Expect exactly 1 fixity check event.
      expect(fixity_check_events.count).to eq 1

      # Grab all events that represent the ingest (there should noly be 1 per FileSet).
      ingest_events = file_set.preservation_events.select do |event|
        event.premis_event_type.first.to_uri.to_s == 'http://id.loc.gov/vocabulary/preservation/eventType/ing'
      end

      # Expect exactly 1 ingest event.
      expect(ingest_events.count).to eq 1

      # Expect the PREMIS agent of the ingest event to be that which is specified in the ingest config.
      premis_agent = ingest_events.first.premis_agent.first.to_uri.to_s
      expect(premis_agent).to eq 'mailto:admin@example.org'
    end
  end
end
