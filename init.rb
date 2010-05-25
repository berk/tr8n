#require "JSON"
#require 'digest/md5'
#require 'pp'


Dir["#{File.dirname(__FILE__)}/lib/core_ext/**/*.rb"].each do |file|
  require file
end

Dir["#{File.dirname(__FILE__)}/app/models/tr8n/*.rb"].each do |file|
  require file
end

Dir["#{File.dirname(__FILE__)}/app/models/tr8n/filters/*.rb"].each do |file|
  require file
end

#Tr8n::Config.models.each do |model|
#  if Tr8n::Config.use_remote_database?
#    model.establish_connection(Tr8n::Config.database)
#  end
#  
#  model.extend(Tr8n::ActiveDumper)
#end  

Rails.configuration.after_initialize do
  ApplicationController.send(:include, Tr8n::CommonMethods)
  ApplicationHelper.send(:include, Tr8n::HelperMethods)
end