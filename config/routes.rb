Rails.application.routes.draw do
  root to: "static_pages#root"

  namespace :api, defaults: {format: :json} do
    resources :products
    resources :prices
    resources :companies
  end 

  resources :users
  resource :session

end
