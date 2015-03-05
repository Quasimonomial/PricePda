Rails.application.routes.draw do
  root to: "static_pages#root"

  namespace :api, defaults: {format: :json} do
    resources :products, except: [:edit, :new] do 
      collection { post :import}
    end
    resources :companies, except: [:edit, :new]
    resource :user_percents, only: [:show, :create]
  end 

  resources :users, only: [:update, :create, :edit, :new]
  resource :session, only: [:create, :new, :destroy]
  resource :email, defaults: {format: :json}, only: []
  post 'email/send_to_all' => 'email#send_to_all'
  post 'email/send_to_self' => 'email#send_to_self'
  resource :excel, only: []
  post 'excel/import_products' => 'excel#import_products'

end
