require 'pp'
require 'will_filter'
require 'tr8n'
require 'rails'

module Tr8n  
  class Engine < Rails::Engine
    config.autoload_paths << File.expand_path("../../lib/core_ext/**", __FILE__)
    config.autoload_paths << File.expand_path("../../lib/tr8n", __FILE__)
    config.autoload_paths << File.expand_path("../../lib/tr8n/tokens", __FILE__)
    config.autoload_paths << File.expand_path("../../app/models/tr8n", __FILE__)
    
    ["../../lib/core_ext/**",
     "../../lib/tr8n",
     "../../lib/tr8n/tokens",
     "../../lib"
     ].each do |dir|
        Dir[File.expand_path("#{File.dirname(__FILE__)}/#{dir}/*.rb")].sort.each do |file|
          require_or_load file
        end
    end    

    initializer "static assets" do |app|
      app.middleware.insert_before(::ActionDispatch::Static, ::ActionDispatch::Static, "#{root}/public")
    end
  end
end
