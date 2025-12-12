Rails.application.routes.draw do
  # Auth routes
  get '/auth/auth0/callback', to: 'sessions#create'
  get '/auth/failure', to: 'sessions#failure'
  get '/logout', to: 'sessions#destroy'
  get '/login', to: 'sessions#new', as: :login
  
  # Root and main pages
  root "homes#index"

resources :games, only: [:index, :show]
resources :users, only: [:index, :show]
resources :reviews, only: [:create, :update, :destroy]
resources :favorite_games, only: [:create]
end