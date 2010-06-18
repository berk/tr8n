require 'rubygems'
require 'test/unit'
require 'shoulda'
require 'mocha'
require 'active_record'

ENV["RAILS_ENV"] = "test"

module Tr8n
end
  
$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__) + "/../lib/tr8n")
$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__) + "/../lib/tr8n/tokens")
$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__) + "/../will_filter/app/models")

# this needs to be fixed - make will_filter into gem
require File.expand_path("#{File.dirname(__FILE__)}/../../will_filter/app/models/model_filter.rb")
require File.expand_path("#{File.dirname(__FILE__)}/../../will_filter/app/models/model_filter_container.rb")

["lib/core_ext/**",
 "lib/tr8n", 
 "lib/tr8n/tokens",
 "../will_filter/app/models"].each do |dir|
    Dir[File.expand_path("#{File.dirname(__FILE__)}/../#{dir}/*.rb")].each do |file|
      require file
    end
end

class Tr8n::Config
  def self.env
    'test'    
  end
  
  def self.root
    @root ||= File.expand_path("#{File.dirname(__FILE__)}/../")
    puts @root
    @root
  end
end

# Load models
["app/models/tr8n", 
 "app/models/tr8n/filters", 
 "app/models/tr8n/metrics",
 "app/models/tr8n/rules",
 "app/models/tr8n/test", 
 "app/models/tr8n/rules/ext"].each do |dir|
    Dir[File.expand_path("#{File.dirname(__FILE__)}/../#{dir}/*.rb")].each do |file|
      require file
    end
end

class Test::Unit::TestCase
end

ActiveRecord::Base.establish_connection(
  :adapter => "sqlite3",
  :database => "db/test.sqlite3",
  :pool => 5,
  :timeout => 5000
)

ActiveRecord::Migration.verbose = false

require File.expand_path("#{File.dirname(__FILE__)}/../generators/templates/migrate/create_tr8n_tables.rb")
CreateTr8nTables.up rescue nil

