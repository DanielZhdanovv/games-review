Rails.application.routes.draw do
  # Auth routes
  get '/auth/auth0/callback', to: 'sessions#create'
  get '/auth/failure', to: 'sessions#failure'
  get '/logout', to: 'sessions#destroy'
  get '/login', to: 'sessions#new', as: :login
  root "homes#index"
  get 'api/games/search', to: 'games#api_search'
  resources :users, only: [:index, :show]
  resources :reviews, only: [:create, :update, :destroy]
  resources :favorite_games, only: [:create, :delete]

  resources :games do
    member do
      get 'api', to: 'games#api_show'
      post 'api/reviews', to: 'games#api_create_review'
      put 'api/reviews/:review_id', to: 'games#api_update_review'
      delete 'api/reviews/:review_id', to: 'games#api_delete_review'
    end
  end
end