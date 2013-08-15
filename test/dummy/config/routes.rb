Rails.application.routes.draw do
  mount WillFilter::Engine => "/will_filter"
  mount Tr8n::Engine => "/tr8n"
  root :to => 'home#index'
  match ':controller(/:action(/:id))(.:format)'
end
