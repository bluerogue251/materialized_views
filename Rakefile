require "bundler/gem_tasks"
require 'active_record'
require 'yaml'
require 'materialized_views'

dbconfig = YAML::load(File.open('db/config.yml'))
ActiveRecord::Base.establish_connection(dbconfig)

# namespace :db do
#   task :create do
#     system 'createdb materialized_views_test'
#   end
#
#   task :drop do
#     system 'dropdb materialized_views_test'
#   end
#
#   task :migrate do
#     system 'dropdb materialized_views_test'
#     system 'createdb materialized_views_test'
#     ActiveRecord::Migrator.migrate('db/migrate')
#   end
# end
