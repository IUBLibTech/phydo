class ApplicationController < ActionController::Base
  helper Openseadragon::OpenseadragonHelper
  # Adds a few additional behaviors into the application controller
  include Blacklight::Controller
  include Hyrax::ThemedLayoutController
  with_themed_layout '1_column'


  # Adds a few additional behaviors into the application controller
  include Blacklight::Controller
  include Hyrax::ThemedLayoutController
  with_themed_layout '1_column'


  # Adds a few additional behaviors into the application controller 
  include Blacklight::Controller
  include Hydra::Controller::ControllerBehavior


  # Adds Hyrax behaviors into the application controller
  include Hyrax::Controller
  # Adds Hyrax behaviors to the application controller.
  include Hyrax::Controller
  include Hyrax::ThemedLayoutController
  with_themed_layout '1_column'


  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
end
