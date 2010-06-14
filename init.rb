#require "JSON"
#require 'digest/md5'
#require 'pp'

["lib/core_ext/**", 
 "app/models/tr8n", 
 "app/models/tr8n/filters", 
 "app/models/tr8n/metrics",
 "app/models/tr8n/rules"].each do |dir|
    Dir["#{File.dirname(__FILE__)}/#{dir}/*.rb"].each do |file|
      require file
    end
end

Tr8n::Config.models.each do |model|
  if Tr8n::Config.use_remote_database?
    model.establish_connection(Tr8n::Config.database)
  end
  
  model.extend(Tr8n::ActiveDumper)
end  

Rails.configuration.after_initialize do
  ApplicationController.send(:include, Tr8n::CommonMethods)
  ApplicationHelper.send(:include, Tr8n::HelperMethods)
end