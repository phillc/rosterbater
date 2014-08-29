Rails.application.routes.draw do
  root to: "welcome#index"

  get 'auth/:provider/callback', to: 'sessions#create_from_omniauth'
  get 'logout', to: 'sessions#destroy'

  resources :games, only: [:index, :show] do
    collection do
      post :refresh
    end

    member do
      post :sync
      post :sync_rankings
      post :link_players
    end

    resources :ranking_profiles, only: [:index]
  end

  resources :leagues, only: [:index, :show] do
    collection do
      post :refresh
    end

    member do
      post :sync
      get :draft_board
    end
  end
end
