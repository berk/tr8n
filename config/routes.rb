ActionController::Routing::Routes.draw do |map|
  [:awards, :chart, :dashboard, :forum, :glossary, :help, :language_cases, 
   :language, :phrases, :translations, :translator, :home, :login].each do |ctrl|   
    map.connect "tr8n/#{ctrl}/:action", :controller => "tr8n/#{ctrl}"
  end

  [:chart, :clientsdk, :forum, :glossary, :language, :translation, :translation_key, :translator].each do |ctrl|   
    map.connect "tr8n/admin/#{ctrl}/:action", :controller => "tr8n/admin/#{ctrl}"
  end
  
  [:language, :translation, :translator].each do |ctrl|   
    map.connect "tr8n/api/v1/#{ctrl}/:action", :controller => "tr8n/api/v1/#{ctrl}"
  end
  
  map.namespace('tr8n') do |tr8n|
    tr8n.root :controller => 'home'
  end
end