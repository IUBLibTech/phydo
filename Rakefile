# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

Rails.application.load_tasks

unless Rails.env == 'production'
  task('spec').clear
  desc 'Run HydraDAM specs'
  task spec: 'hydradam:spec'

  desc 'Run HydraDAM CI tests'
  task ci: 'spec'

  task default: 'ci'
end
