# Generated via
#  `rails generate hyrax:work Work`

class Hyrax::WorksController < ApplicationController
  include Hyrax::CurationConcernController
  self.curation_concern_type = Work
  self.show_presenter = Hyrax::WorkPresenter
end
