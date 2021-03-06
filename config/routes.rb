Myflix::Application.routes.draw do

  resources :videos, only: :show do
    collection do
      post 'search'
      get :advanced_search
    end

    resources :reviews, only: :create
  end

  namespace :admin do
    resources :videos, only: [:new, :create]
    resources :payments, only: [:index]
  end

  resources :categories, only: :show

  get 'sign_in', to: 'sessions#new'
  post 'sign_in', to: 'sessions#create'
  get 'sign_out', to: 'sessions#destroy'
  get 'register', to: 'users#new'
  post 'register', to: 'users#create'
  get 'billing', to: 'users#billing'

  resources :users, only: [:show, :edit, :update], path: '/account'

  get 'forgot_password', to: 'forgot_passwords#new'
  resources :forgot_passwords, only: [:create]
  get 'forgot_password_confirmation', to: 'forgot_passwords#confirm'

  resources :reset_passwords, only: [:show, :update]
  get 'expired_password_reset_token', to: 'reset_passwords#expired_token'

  get :people, to: 'relationships#index'
  resources :relationships, only: [:create, :destroy]

  resource :invites, only: [:new, :create]

  post 'update_queue', to: 'queue_items#update_queue'

  resources :queue_items, only: [:create, :destroy, :index], path: '/my_queue'

  mount StripeEvent::Engine => '/stripe-events' # provide a custom path

  root to: 'pages#front'
  get 'ui(/:action)', controller: 'ui'
  get 'home', to: 'videos#index'
end
