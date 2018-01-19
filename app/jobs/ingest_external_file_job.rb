class IngestExternalFileJob < ActiveJob::Base
  queue_as Hyrax.config.ingest_queue_name

  # @param [FileSet] file_set
  # @param [String] external_uri the URI that will be put into the external-body MIME type
  # @param [User] user
  # @option opts [String] mime_type
  # @option opts [String] filename
  # @option opts [String] relation, ex. :original_file
  def perform(file_set, external_uri, user, opts = {})
    relation = opts.fetch(:relation, :original_file).to_sym

    # Tell AddFileToFileSet service to skip versioning because versions will be minted by
    # VersionCommitter when necessary during save_characterize_and_record_committer.
    Hydra::Works::AddExternalFileToFileSet.call(file_set,
                                        external_uri,
                                        relation,
                                        versioning: false)

    # Persist changes to the file_set
    file_set.save!

    repository_file = file_set.send(relation)

    # Do post file ingest actions
    Hyrax::VersioningService.create(repository_file, user)
  end
end
