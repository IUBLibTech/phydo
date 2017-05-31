module Phydo
  module FileActor
    module IngestFileNow
      # Monkeypatch to change the perform_later call to perform_now
      # Resolves bug with 2nd+ files not attaching to FileSet
      def ingest_file(file, asynchronous)
        IngestFileJob.perform_now(
          file_set,
          working_file(file),
          user,
          ingest_options(file))
        true
      end
    end
  end
end
