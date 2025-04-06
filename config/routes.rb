Rails.application.routes.draw do
  resources :labels
  resources :tasks
  get "sessions/new"
  get "sessions/create"
  get "sessions/destroy"
  get "users/new"
  get "users/create"
  get "users/login"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
  root "users#show"
  get "signup", to: "users#new"
  post "signup", to: "users#create"
  get "login", to: "sessions#new"
  post "login", to: "sessions#create"
  get "dashboard", to: "users#dashboard"

  delete "logout", to: "sessions#destroy"
  resources :users, only: [ :new, :create, :update ]

  resources :labels do
    resources :tasks, only: [ :create, :update, :destroy ], shallow: true
  end

  resources :tasks do
    member do
      patch :update_status
    end
  end

  resources :tasks
end
