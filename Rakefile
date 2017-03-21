# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

Rails.application.load_tasks

unless Rails.env == 'production'
  task('spec').clear
  desc 'Run Phydo specs'
  task spec: 'phydo:spec'

  desc 'Run Phydo CI tests'
  task ci: 'spec'

  task default: 'ci'
end
