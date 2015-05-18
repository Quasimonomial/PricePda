Rails.application.routes.draw do
  root to: "static_pages#root"

  namespace :api, defaults: {format: :json} do
    get 'products/distinct_categories' => 'products#distinct_categories'
    resources :products, except: [:edit, :new]
    post 'products/mass_user_prices'
    post 'products/mass_product_data'
    get 'products/:id/historical_prices' => 'products#historical_prices'
    resources :companies, except: [:edit, :new]
    resource :user_percents, only: [:show, :create]
  end 

  resources :users, only: [:update, :create, :edit, :new]
  resource :session, only: [:create, :new, :destroy]
  resource :email, defaults: {format: :json}, only: []
  post 'email/send_to_all' => 'email#send_to_all'
  post 'email/send_to_self' => 'email#send_to_self'
  post 'email/resend_activation_email' => 'email#resend_activation_email'
  resource :excel, only: []
  post 'excel/import_products' => 'excel#import_products'
  post 'excel/upload_user_prices' => 'excel#upload_user_prices'
  post 'excel/import_company_prices' => 'excel#import_company_prices'
  get 'excel/export_user_uploads' => 'excel#export_user_uploads'
  get 'excel/export_user_data' => 'excel#export_user_data' 

  get 'excel/seeded_products' => 'excel#seeded_products' 
  get 'excel/seeded_user_uploads' => 'excel#seeded_user_uploads' 
  get 'excel/seeded_price_uploads' => 'excel#seeded_price_uploads'

  resources :account_activations, only: [:edit]
  resources :password_resets,     only: [:new, :create, :edit, :update]
end
