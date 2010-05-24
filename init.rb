#require "JSON"
#require 'digest/md5'
#require 'pp'

def load_classes
  Dir["#{File.dirname(__FILE__)}/lib/core_ext/**/*.rb"].each do |file|
    require file
  end
  
  Dir["#{File.dirname(__FILE__)}/app/models/tr8n/filters/*.rb"].each do |file|
    require file
  end
end

load_classes

Rails.configuration.after_initialize do
  ApplicationController.send(:include, Tr8n::CommonMethods)
  ApplicationHelper.send(:include, Tr8n::HelperMethods)
end