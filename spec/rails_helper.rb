# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?
require 'spec_helper'
require 'rspec/rails'
require 'capybara/rspec'
require 'capybara/rails'
require 'rails-controller-testing'
require 'active_fedora/cleaner'

# Add additional requires below this line. Rails is not loaded until this point!

require 'factory_bot'

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
#
# The following line is provided for convenience purposes. It has the downside
# of increasing the boot-up time by auto-requiring all files in the support
# directory. Alternatively, in the individual `*_spec.rb` files, manually
# require only the support files necessary.
#
# Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

# Checks for pending migrations before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = false

  # Use conventional locations to infer the spec type, rather than requiring
  # metadata to indicate the spec type.
  config.infer_spec_type_from_file_location!

  # Include methods for logging in, etc.
  config.include Warden::Test::Helpers

  # Devise helpers
  # From https://github.com/plataformatec/devise#test-helpers
  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include Devise::TestHelpers, type: :view

  # Use FactoryBot shortcut methods, like `create` instead of `FactoryBot.create`
  config.include FactoryBot::Syntax::Methods


  config.before(:suite) do
    # Handle database cleaning
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.clean_with :truncation

    # Find factory definitions.
    FactoryBot.find_definitions
  end

  config.before(:each) do |example|
    # Pass `:clean' to destroy objects in fedora/solr and start from scratch
    ActiveFedora::Cleaner.clean! if example.metadata[:clean_fedora]
    DatabaseCleaner.start
  end


  # Taken from Hyku
  # See:https://github.com/projecthydra-labs/hyku/blob/5a9eb5655a4216986acb39763f290e3d4c51d3a4/spec/rails_helper.rb
  config.after(:each, type: :feature) do
    Warden.test_reset!
    Capybara.reset_sessions!
    page.driver.reset!
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end
