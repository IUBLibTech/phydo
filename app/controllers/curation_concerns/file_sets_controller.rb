module CurationConcerns
  class FileSetsController < ApplicationController
    include CurationConcerns::FileSetsControllerBehavior
    include ::StorageControllerBehavior

    # override FileSetControllerBehavior to use customized presenter class
    self.show_presenter = Phydo::FileSetPresenter
  end
end
