ActionController::Routing::Routes.draw do |map|
  map.namespace('tr8n') do |tr8n|
    tr8n.root :controller => 'dashboard'
  end
end