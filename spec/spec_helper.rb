require_relative '../config/active_record_connection'
require 'support/model_class_definitions'
require 'materialized_views'

RSpec.configure do |config|
  config.before(:each) do
    Client.delete_all
    MaterializedClient.delete_all
  end
end
