source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.1.3'
# Use sqlite3 as the database for Active Record
gem 'sqlite3'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2'
# See https://github.com/rails/execjs#readme for more supported runtimes
gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Unicorn as the app server
# gem 'unicorn'
gem 'puma'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'

  # Add ruby implementation of readline to the bundle. This is easier than
  # resolving the dependencies for various opertating systems.
  gem 'rb-readline'
end

group :development, :test do
  gem 'rspec-rails'
  gem 'capybara'
  gem 'webmock'
  gem 'coveralls', require: false
  gem 'rails-controller-testing'
  gem 'guard-rspec', require: false
  gem 'guard-rubocop', require: false
  gem 'rubocop', '~> 0.49', require: false
  gem 'rubocop-rspec', '~> 1.20.1', require: false
  gem 'simplecov', require: false
  gem 'byebug'
  gem 'pry-rails'
  gem 'pry-nav'
  gem "factory_girl_rails", "~> 4.0", require: false
  gem 'launchy'
  gem 'database_cleaner'
end

gem 'hyrax', '~> 1.0.5'
gem 'devise'

gem 'omniauth-cas'
gem 'archive-tar-minitar', '~> 0.5.2'
gem 'blacklight_range_limit', github: 'projectblacklight/blacklight_range_limit', branch: 'master'
gem 'hyrax-ingest', github: 'IUBLibTech/hyrax-ingest', branch: 'master'
gem 'hyrax-preservation', github: 'IUBLibTech/hyrax-preservation', branch: 'master'
gem 'external_storage', github: 'samvera-labs/samvera-external_storage'
gem 'storage_proxy_api', github: 'samvera-labs/storage_proxy_api'

# Pin rdf-vocab to 2.2.8 since 2.2.9 introduced breaking changes
gem 'rdf-vocab', '2.2.8'

# CC v2.0.0 seems to not include BL advanced search anymore?
gem 'blacklight_advanced_search', '~> 6.2.1'
gem 'devise-guests', '~> 0.5'

group :development, :test do
  gem 'fcrepo_wrapper'
  gem 'solr_wrapper', '>= 0.3'
end

# Pin rdf-vocab to 2.2.8 because 2.2.9 updates the EBUCore ontology (and the ruby interface used to get the URIs).
# Updating the gem will require updating which EBU predicates we're using.
gem 'rdf-vocab', '2.2.8'