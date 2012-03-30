Ccromembers::Application.routes.draw do

  match 'login' => 'sessions#new', :as => :login
  match 'logout' => 'sessions#destroy', :as => :logout
  match 'register' => 'people#new', :as => :register
  match 'dashboard' => 'reports#dashboard', :as => :dashboard

  get 'forgot_password' => 'password_resets#new', :as => :forgot_password
  post 'forgot_password' => 'password_resets#create', :as => :forgot_password
  get 'reset_password/:perishable_token' => 'password_resets#edit', :as => :reset_password
  put 'reset_password/:perishable_token' => 'password_resets#update', :as => :reset_password

  resource :sessions
  resources :people
  resources :companies
  resources :comments
  resources :messages do
    resources :comments
  end
  resources :documents do
    resources :comments
  end

  root :to => 'sessions#new'

  match ':controller(/:action(/:id))(.:format)'
end
