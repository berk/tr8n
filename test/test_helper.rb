# this will need to go away once 
$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__) + "/../../will_filter/app/models")

require 'pp'

ENV["RAILS_ENV"] = "test"

require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'test_help'


# create database tables
Dir[File.expand_path("#{File.dirname(__FILE__)}/../db/migrate/*.rb")].each do |file|
  require file
end

CreateTr8nTables.up rescue nil
CreateTestUsers.up rescue nil
