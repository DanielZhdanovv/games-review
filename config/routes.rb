# config/routes.rb
Rails.application.routes.draw do
  # Let OmniAuth handle all auth routes starting with /auth/
  # Don't define /auth/auth0 as a Rails route at all
  
  get '/auth/auth0/callback', to: 'sessions#create'
  get '/auth/failure', to: 'sessions#failure'
  get '/logout', to: 'sessions#destroy'
  get '/login', to: 'sessions#new', as: :login

  root "homes#index"
  
  namespace :api do
    namespace :v1 do
      resources :games, only: [:index, :show]
      resources :reviews, only: [:show, :create, :edit, :update, :destroy]
      resources :users, only: [:index, :show]
      resources :favorite_games, only: [:index, :create]
    end
  end
end