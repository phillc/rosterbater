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
      get :upload_rankings
      post :update_rankings
      post :link_players
    end

    resources :ranking_profiles, only: [:index]
  end

  resource :info, only: [:show]

  resources :leagues, only: [:index, :show] do
    collection do
      post :refresh
      get :currently_refreshing
    end

    member do
      post :sync
      get :weekly
      get :players
      get :draft_board
      get :playoffs
      get :parity
      get :charts
    end
  end
end
