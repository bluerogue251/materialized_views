require "bundler/gem_tasks"
require 'active_record'
require 'yaml'

dbconfig = YAML::load(File.open('db/config.yml'))
ActiveRecord::Base.establish_connection(dbconfig)

# require_relative 'db/migrate/001_create_unmaterialized_clients'
# require 'db/migrate/002_create_materialized_clients'

task :migrate do
  ActiveRecord::Migrator.migrate('db/migrate')
  # CreateUnmaterializedClients.new.migrate
  # CreateMaterializedClients.new.migrate!
end
