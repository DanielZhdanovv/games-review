Rails.application.routes.draw do
  devise_for :users
  
  devise_scope :user do
    get '/users/sign_out' => 'devise/sessions#destroy'
  end
  
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