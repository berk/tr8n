Tr8nServer::Application.routes.draw do
  mount Tr8n::Engine => "/tr8n"
  mount WillFilter::Engine => "/will_filter"

  root :to => "home#index"

  [:admins, :users].each do |ctrl|
    match "/admin/#{ctrl}(/:action)", :controller => "admin/#{ctrl}"
  end

  namespace :admin do
    root :to => "users#index"
  end
  
  match ':controller(/:action(/:id(.:format)))'
end
