# Generated via
#  `rails generate hyrax:work Work`

module Hyrax
  class WorksController < ApplicationController
    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    self.curation_concern_type = ::Work
    self.show_presenter = Phydo::WorkPresenter
  end
end
