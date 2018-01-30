module Hyrax
  class FileSetsController < ApplicationController
    include Hyrax::FileSetsControllerBehavior
    include ExternalStorage::ExternalFileSetBehavior

    # override FileSetControllerBehavior to use customized presenter class
    self.show_presenter = Phydo::FileSetPresenter

    def fixity
       path = polymorphic_path([main_app, curation_concern])
       job = FixityCheckJob.new(user: current_user, ids: [curation_concern.id])
       job.run
       redirect_to path, notice: "Fixity check requested."
    end
  end
end
