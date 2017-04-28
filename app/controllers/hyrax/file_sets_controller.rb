module Hyrax
  class FileSetsController < ApplicationController
    include Hyrax::FileSetsControllerBehavior
    include ::StorageControllerBehavior

    # override FileSetControllerBehavior to use customized presenter class
    self.show_presenter = Phydo::FileSetPresenter
  end
end
