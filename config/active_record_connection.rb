require 'active_record'
require 'yaml'

dbconfig = YAML::load(File.open('db/config.yml'))["test"]
ActiveRecord::Base.establish_connection(dbconfig)

