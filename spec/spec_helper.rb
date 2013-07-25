ENV["RAILS_ENV"] = "test"

require 'pp'
require 'spork'

Spork.prefork do

	require File.expand_path("../../sample/service/config/environment.rb",  __FILE__)
	require 'rspec/rails'

	ENGINE_RAILS_ROOT=File.join(File.dirname(__FILE__), '../')

	# Requires supporting ruby files with custom matchers and macros, etc,
	# in spec/support/ and its subdirectories.
	Dir[File.join(ENGINE_RAILS_ROOT, "spec/support/**/*.rb")].each {|f| require f }

	RSpec.configure do |config|
	  config.use_transactional_fixtures = true
      config.use_instantiated_fixtures  = false	  
	end

end


Spork.each_run do
  # This code will be run each time you run your specs.

end
