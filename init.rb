#require "JSON"
#require 'digest/md5'
require 'pp'

["lib/core_ext/**",
 "lib/tr8n",
 "app/models/tr8n", 
 "app/models/tr8n/filters", 
 "app/models/tr8n/metrics",
 "app/models/tr8n/rules",
 "app/models/tr8n/test", 
 "app/models/tr8n/rules/ext"].each do |dir|
    Dir[File.expand_path("#{File.dirname(__FILE__)}/#{dir}/*.rb")].each do |file|
      require file
    end
end

Tr8n::Config.models.each do |model|
  model.extend(Tr8n::ActiveDumper)
end  

Rails.configuration.after_initialize do
  begin
    ApplicationController.send(:include, Tr8n::CommonMethods)
    ApplicationHelper.send(:include, Tr8n::HelperMethods)
  rescue NameError => er
    pp er
  end 
end
  