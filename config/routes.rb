Ccromembers::Application.routes.draw do
  
  
  resources :smart_lists

  get "call_manager/sms"

  get "call_manager/voice"

  resources :polls do
    member do
      get 'pick_a'
      get 'pick_b'
      get 'pick_c'
      get 'pick_d'
      get 'deactivate'
      get 'activate'
      get 'report'
    end
    collection do
      get 'active'
    end
  end

  resources :polling_sessions do
    member do
      get 'report'
    end
  end

  get "exceptions/accessdenied", as: 'exceptions_accessdenied'

  resources :signups, :only => ['index', 'new', 'create'] do
    collection do 
      get :basic
      get :pro
      get :return
    end    
  end
  
  resources :subscriptions

  resources :tags

  resources :groups

    namespace :mercury do
      resources :images
    end

  mount Mercury::Engine => '/'
    
    resources :posts do
      
      resources :comments

      collection do
        get :draft
      end
      
      member do 
        post :mercury_update
        get :publish
        get :claim
        get :reset_token
        get :duplicate
        get :restore
        post :share
      end
    end

    resources :pages do
      
      resources :comments

      collection do
        get :draft
      end
      
      member do 
        post :mercury_update
        get :publish
        get :claim
        get :reset_token
        get :duplicate
        get :restore
        post :share
      end
    end

    match 'tag/:tag_name' => 'posts#index', as: 'tagged_posts'
    match 'archive' => 'posts#index', :defaults => { filter: 'archive' }, as: 'archive_posts'
    match 'drafts' => 'posts#index', :defaults => { filter: 'drafts' }, as: 'draft_posts'
    match 'my_drafts' => 'posts#index', :defaults => { filter: 'my_drafts' }, as: 'my_draft_posts'
    match 'summit' => 'posts#index', :defaults => { filter: 'summit' }, as: 'summit_posts'
    match 'shared_post/:token' => 'posts#show', as: 'shared_post'

    match 'message_tag/:tag_name' => 'messages#index', as: 'tagged_messages'



    constraints(:host => 'polls.ccro.org') do
      root :to => 'polls#active'
    end

    match 'page_tag/:tag_name' => 'pages#index', as: 'tagged_pages'
    match 'page_archive' => 'pages#index', :defaults => { filter: 'archive' }, as: 'archive_pages'
    match 'page_drafts' => 'pages#index', :defaults => { filter: 'drafts' }, as: 'draft_pages'
    match 'my_page_drafts' => 'pages#index', :defaults => { filter: 'my_drafts' }, as: 'my_draft_pages'
    match 'active_pages' => 'pages#index', :defaults => { filter: 'active' }, as: 'active_pages'
    match 'summit_page' => 'pages#index', :defaults => { filter: 'summit' }, as: 'summit_pages'
    match 'shared_page/:token' => 'pages#show', as: 'shared_page'

  
    root :to => 'posts#index'


    namespace :admin do
      resources :people
      resources :companies
    end
    resources :comments
    resources :messages, :path => 'discussions' do
      resources :comments
      member do
        get :archive
        get :unarchive
      end
    end
    resources :documents do
      member { post :mercury_update }
      resources :comments
    end
    match 'shared_document/:token' => 'documents#show', as: 'shared_document'
 
  match 'login' => 'sessions#new', :as => :login
  match 'logout' => 'sessions#destroy', :as => :logout
  match 'register' => 'people#new', :as => :register
  match 'dashboard' => 'reports#dashboard', :as => :dashboard
  match 'unsupported_browser' => 'static#unsupported_browser', :as => :hell
  get 'forgot_password' => 'password_resets#new', :as => :forgot_password
  post 'forgot_password' => 'password_resets#create', :as => :forgot_password
  get 'reset_password/:perishable_token' => 'password_resets#edit', :as => :reset_password
  put 'reset_password/:perishable_token' => 'password_resets#update', :as => :reset_password
  get 'activation' => 'sessions#activation', :as => :activation
  post 'activate(/:activation_token)' => 'sessions#activate', :as => :activate
  get 'activate(/:activation_token)' => 'sessions#activate'

  match 'forbidden' => 'static#403', :as => :forbidden
  match 'new_poll(/:polling_session)' => 'polls#new_for_session', as: :new_poll_for_session

  
  resource :sessions
  
  resources :people do
      member do
        get :resend_activation
        get :send_mobile_activation
      end
      resources :subscriptions
  end

  resources :companies do
      resources :subscriptions
  end

  resources :surveys do
    resources :questions do
      resources :responses
      member do
        post :new_response
        get :destroy_response
      end
     end
     
    
    member do 
      get :report
    end
    
    collection { post :sort }
  end  
  
  match ':controller(/:action(/:id))(.:format)'
end
