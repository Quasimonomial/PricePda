Rails.application.routes.draw do
  root to: "static_pages#root"

  namespace :api, defaults: {format: :json} do
    resources :products
    resources :companies
    resources :user
  end 

  resources :users
  resource :session

end
