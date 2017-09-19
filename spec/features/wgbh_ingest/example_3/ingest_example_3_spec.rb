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

  it 'ingests a single preservation event with PREMIS event type of "Ingest" and PREMIS agent of mailto:admin@example.org', :clean_fedora, :large_ingest do
    FileSet.all.each do |file_set|
      # Expect exactly 1 preservation event.
      expect(file_set.preservation_events.count).to eq 1

      # Expect the PREMIS event type to be that which was specified in the ingest config YAML.
      premis_event_type_uri = file_set.preservation_events.first.premis_event_type.first.to_uri.to_s
      expect(premis_event_type_uri).to eq 'http://id.loc.gov/vocabulary/preservation/eventType/ing'

      # Expect the PREMIS agent to be that which was specified in the ingest config YAML.
      premis_agent = file_set.preservation_events.first.premis_agent.first.to_uri.to_s
      expect(premis_agent).to eq 'mailto:admin@example.org'
    end
  end
end
