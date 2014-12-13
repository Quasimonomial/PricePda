Rails.application.routes.draw do
  root to: "static_pages#root"

  resources :products
  resources :price
  resources :companies

  resources :users
  resource :session

end
