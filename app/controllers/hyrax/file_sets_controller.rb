module Hyrax
  class FileSetsController < ApplicationController
    include Hyrax::FileSetsControllerBehavior
    include ExternalStorage::ExternalFileSetBehavior

    # override FileSetControllerBehavior to use customized presenter class
    self.show_presenter = Phydo::FileSetPresenter

    def fixity
      FixityCheckJob.new(user: current_user, ids: [curation_concern.id]).run
      redirect_to polymorphic_path([main_app, curation_concern]), notice: "Fixity check requested."
    end
  end
end
