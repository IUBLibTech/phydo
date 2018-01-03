class Phydo::FileActor < Hyrax::Actors::FileActor
  # Puts the uploaded content into a staging directory. Then kicks off a
  # job to ingest the file into the repository, then characterize and
  # create derivatives with this on disk variant.
  # TODO: create a job to monitor this directory and prune old files that
  # have made it to the repo
  # @param [File, ActionDigest::HTTP::UploadedFile, Tempfile] file the file to save in the repository
  # @param [Boolean] asynchronous set to true if you want to launch a new background job.
  def ingest_file(uri, asynchronous)
    IngestExternalFileJob.perform_now(file_set, uri, user, {})
    true
  end
end
