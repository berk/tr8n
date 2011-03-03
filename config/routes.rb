#TR8n::Application.routes.draw do
#  match 'tr8n/awards/:action' => 'tr8n/awards#index'
#  match 'tr8n/chart/:action' => 'tr8n/chart#index'
#  match 'tr8n/dashboard/:action' => 'tr8n/dashboard#index'
#  match 'tr8n/forum/:action' => 'tr8n/forum#index'
#  match 'tr8n/glossary/:action' => 'tr8n/glossary#index'
#  match 'tr8n/help/:action' => 'tr8n/help#index'
#  match 'tr8n/language_cases/:action' => 'tr8n/language_cases#index'
#  match 'tr8n/language/:action' => 'tr8n/language#index'
#  match 'tr8n/phrases/:action' => 'tr8n/phrases#index'
#  match 'tr8n/translations/:action' => 'tr8n/translations#index'
#  match 'tr8n/translator/:action' => 'tr8n/translator#index'
#  match 'tr8n/home/:action' => 'tr8n/home#index'
#  match 'tr8n/login/:action' => 'tr8n/login#index'
#  match 'tr8n/admin/chart/:action' => 'tr8n/admin/chart#index'
#  match 'tr8n/admin/clientsdk/:action' => 'tr8n/admin/clientsdk#index'
#  match 'tr8n/admin/forum/:action' => 'tr8n/admin/forum#index'
#  match 'tr8n/admin/glossary/:action' => 'tr8n/admin/glossary#index'
#  match 'tr8n/admin/language/:action' => 'tr8n/admin/language#index'
#  match 'tr8n/admin/translation/:action' => 'tr8n/admin/translation#index'
#  match 'tr8n/admin/translation_key/:action' => 'tr8n/admin/translation_key#index'
#  match 'tr8n/admin/translator/:action' => 'tr8n/admin/translator#index'
#  match 'tr8n/admin/domain/:action' => 'tr8n/admin/domain#index'
#  match 'tr8n/api/v1/language/:action' => 'tr8n/api/v1/language#index'
#  match 'tr8n/api/v1/translation/:action' => 'tr8n/api/v1/translation#index'
#  match 'tr8n/api/v1/translator/:action' => 'tr8n/api/v1/translator#index'
#  match 'tr8n/' => 'tr8n/home#index'
#  namespace :tr8n do
#  end
#end

#ActionController::Routing::Routes.draw do |map|
#  [:awards, :chart, :dashboard, :forum, :glossary, :help, :language_cases, 
#   :language, :phrases, :translations, :translator, :home, :login].each do |ctrl|   
#    map.connect "tr8n/#{ctrl}/:action", :controller => "tr8n/#{ctrl}"
#  end
#
#  [:chart, :clientsdk, :forum, :glossary, :language, :translation, :translation_key, :translator, :domain].each do |ctrl|   
#    map.connect "tr8n/admin/#{ctrl}/:action", :controller => "tr8n/admin/#{ctrl}"
#  end
#  
#  [:language, :translation, :translator].each do |ctrl|   
#    map.connect "tr8n/api/v1/#{ctrl}/:action", :controller => "tr8n/api/v1/#{ctrl}"
#  end
#  
#  map.namespace('tr8n') do |tr8n|
#    tr8n.root :controller => 'home'
#  end
#end
