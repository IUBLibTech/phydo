require 'rails_helper'
require 'rake'

describe 'Running checksum comparisons after ingest' do

  before do
    # Create FileSets that will be updated with values from 'checksums.csv'.
    ['123', '456'].each do |file_set_id|
      FileSet.new.tap do |file_set|
        file_set.id = file_set_id
        file_set.save!
      end
    end

    # Load the app's rake tasks/
    Phydo::Application.load_tasks

    # Set ENV vars that would normally be passed in from the cmd line to the rake task.
    ENV['config_file'] = "./spec/features/wgbh_ingest/run_checksum_comparison/run_checksum_comparison.yml"
    ENV['shared_sip_path'] = './spec/features/wgbh_ingest/run_checksum_comparison'
    # iterate over all lines of the shared CSV
    ENV['iterations'] = '4'
    ENV['compare_checksums'] = '1'
    ENV['user']= 'admin@example.org'

    # Run the rake task, and fail the test if it raises an error.
    # NOTE: If the rake task raises an error and we don't fail the test,
    #   then Rspec will skip the examples, and the test will pass. This is bad.
    expect { Rake::Task['phydo:ingest'].invoke }.to_not raise_error
  end

  let(:fixity_check_event_1) { FileSet.find('123').fixity_events.first }
  let(:fixity_check_event_2) { FileSet.find('456').fixity_events.first }
  let(:fixity_premis_event_type) { Hyrax::Preservation::PremisEventType.find_by_abbr('fix') }

  it 'adds the Fixity preservation event with correct outcome from doing checksum comparison' do
    expect(fixity_check_event_1.premis_event_type.first.id).to eq fixity_premis_event_type.uri
    expect(fixity_check_event_1.premis_event_outcome.first).to eq "pass"
    expect(fixity_check_event_2.premis_event_type.first.id).to eq fixity_premis_event_type.uri
    expect(fixity_check_event_2.premis_event_outcome.first).to eq "fail"
  end
end