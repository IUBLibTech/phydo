# Do not build this rake task when in production environment.
if Rails && !Rails.env.production?
  namespace :phydo do

    desc 'Phydo rspec task'
    RSpec::Core::RakeTask.new(:rspec) do |task|
      task.rspec_opts      = ENV['RSPEC_OPTS']            if ENV['RSPEC_OPTS'].present?
      task.pattern         = ENV['RSPEC_PATTERN']         if ENV['RSPEC_PATTERN'].present?
      task.exclude_pattern = ENV['RSPEC_EXCLUDE_PATTERN'] if ENV['RSPEC_EXCLUDE_PATTERN'].present?
    end

    desc 'Run tests as if on CI server'
    task :spec do
      ENV['RAILS_ENV'] = 'test'
      ENV['TRAVIS'] = '1'

      FcrepoWrapper.wrap(config: Rails.root.join('.fcrepo_wrapper.test.yml')) do |fc|
        # TODO: get values from .solr-wrapper ?
        SolrWrapper.wrap(config: Rails.root.join('.solr_wrapper.test.yml')) do |solr|
          solr.with_collection name: 'phydo-test', dir: File.join(Rails.root, 'solr', 'config') do
            Rake::Task['phydo:rspec'].invoke
          end
        end
      end
    end
  end
end