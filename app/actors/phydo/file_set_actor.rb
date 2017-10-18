class Phydo::FileSetActor < Hyrax::Actors::FileSetActor
  # Called from AttachFilesActor, FileSetsController, AttachFilesToWorkJob, ImportURLJob, IngestLocalFileJob
  # @param [File, ActionDigest::HTTP::UploadedFile, Tempfile] file the file uploaded by the user.
  # @param [String] relation ('original_file')
  # @param [Boolean] asynchronous (true) set to false if you don't want to launch a new background job.
  def create_content(file_name, uri, relation = 'original_file', asynchronous = true)
    # If the file set doesn't have a title or label assigned, set a default.
    file_set.label ||= Array.wrap(file_name).first
    file_set.title = [file_set.label] if file_set.title.blank?
    return false unless file_set.save # Need to save the file_set in order to get an id
    build_file_actor(relation).ingest_file(uri, asynchronous)
    true
  end

  def file_actor_class
    Phydo::FileActor
  end
end
