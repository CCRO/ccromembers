Ccromembers::Application.routes.draw do

  Mercury::Engine.routes

  constraints(:domain => 'ccro.dev') do
    namespace :blog, :path => '/' do
      resources :posts do
        member { post :mercury_update }
      end
    end
    
    root :to => 'blog/posts#index'
  end
  
  constraints(:domain => 'ccromembers.dev') do
  
    namespace :admin do
      resources :people
      resources :companies
    end
    resources :comments
    resources :messages, :path => 'discussions' do
      resources :comments
    end
    resources :documents do
      member { post :mercury_update }
      resources :comments
    end

    root :to => 'sessions#new'

    match ':controller(/:action(/:id))(.:format)'
  end
  
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
  
  
end
