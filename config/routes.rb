Rails.application.routes.draw do
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  get '/about' => 'home#about'
  get '/admin' => 'admin#show'
  patch '/admin' => 'admin#settle'
  resources :bookings
  resources :payments

  root 'home#index'
end
