namespace :phydo do
  desc "Perform an ingest using Hyrax-ingest gem, with additional params"
  task ingest: :environment do
    config_file_path = ENV['config_file']
    # Globbed paths represent batches, so expand them and add to the list of sip_paths.
    sip_paths = ENV['sip_paths'].to_s.split(',').map! do |sip_path|
      batch = Dir.glob(sip_path)
      batch.empty? ? sip_path : batch
    end.flatten
    shared_sip_path = ENV['shared_sip_path']
    iterations = ENV['iterations']

    if !config_file_path || (sip_paths.empty? && !shared_sip_path)
      abort "Error: Invalid Parameters\n\nUsage: rake hyrax:ingest config_file=FILE [sip_paths=PATH1[,PATH2,...]] [shared_sip_path=SHARED_PATH]\n\n"
    end

    batch_runner = Hyrax::Ingest::BatchRunner.new(config_file_path: config_file_path, sip_paths: sip_paths, shared_sip_path: shared_sip_path, iterations: iterations)
    batch_runner.run!
    ingested_file_set_ids = batch_runner.ingested_ids_by_type[FileSet]
    if ENV['compare_checksums'] && ingested_file_set_ids
      FixityCheckJob.new(user: ENV['user'], ids: ingested_file_set_ids).run
    end
  end
end