require "bundler/gem_tasks"
require 'db/migrate/001_create_unmaterialized_clients'
require 'db/migrate/002_create_materialized_clients'

task :migrate do
  CreateUnmaterializedClients.new.migrate!
  CreateMaterializedClients.new.migrate!
end
