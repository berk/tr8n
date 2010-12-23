# Settings specified here will take precedence over those in config/environment.rb

# In the development environment your application's code is reloaded on
# every request.  This slows down response time but is perfect for development
# since you don't have to restart the webserver when you make code changes.
config.cache_classes = true
ActionView::Base.cache_template_loading = false

# Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = true
config.action_view.debug_rjs                         = true
config.action_controller.perform_caching             = false

# Don't care if the mailer can't send
config.action_mailer.raise_delivery_errors = false

config.action_controller.session = { :key => "_dev_session", :secret => "218d878f47b437169e7de9975d2e1286" }

[
 "../../lib/core_ext/**",
 "../../lib/tr8n", 
 "../../lib/tr8n/tokens"
].each do |dir|
    Dir[File.expand_path("#{File.dirname(__FILE__)}/#{dir}/*.rb")].sort.each do |file|
      require_or_load file
    end
end
