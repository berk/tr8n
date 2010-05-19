#require "JSON"
#require 'digest/md5'
#require 'pp'

def load_core_extensions
  Dir["#{File.dirname(__FILE__)}/lib/core_ext/**/*.rb"].each do |file|
    require file
  end
end

load_core_extensions

Rails.configuration.after_initialize do
  ApplicationController.send(:include, Tr8n::CommonMethods)
  ApplicationHelper.send(:include, Tr8n::HelperMethods)
end