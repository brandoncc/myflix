Myflix::Application.routes.draw do
  root to: 'pages#front'
  get '/home', to: 'videos#index'
  get 'ui(/:action)', controller: 'ui'
  get '/registration', to: 'users#new'
  
  get '/login', to: 'sessions#new'
  post '/login', to: 'sessions#create'
  get '/logout', to: 'sessions#destroy'
  get '/people', to: 'friendships#index' 
  get '/my_queue', to: 'my_queue_videos#index'
  post '/update_queue_videos', to: 'my_queue_videos#update_queue_videos'

  get '/forgot_password', to: 'forgot_password#new'
  get '/confirm_email_send', to: 'forgot_password#confirm'
  get '/reset_password', to: 'reset_password#show'
  get '/token_expire', to: 'reset_password#expire'
  get '/invitation_expire', to: 'invitations#expire'

  get '/register/:token', to: 'invitations#accept_invitation', as: 'register_with_token'

  resources :videos do
    collection do
      get 'search'
    end
    resources :reviews, only: [:create]
  end
  resources :categories, only: [:show, :new, :create]  
  resources :users, only: [:show, :create, :edit, :update]

  resources :friendships, except: [:show, :new, :edit]  
  
  resources :my_queue_videos, only: [:create, :destroy, :index]
  
  resources :forgot_password, only: [:create]  
  resources :reset_password, only: [:create]

  resources :invitations, only: [:new, :create]

end
