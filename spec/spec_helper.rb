require 'active_record'
require 'yaml'
require 'materialized_views'

dbconfig = YAML::load(File.open('db/config.yml'))
ActiveRecord::Base.establish_connection(dbconfig)

# RSpec.configure do |config|
#   config.before(:each) do
#     UnmaterializedClient.delete_all
#     MaterializedClient.delete_all
#   end
# end
