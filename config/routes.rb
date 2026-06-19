Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  root "home#index"
  get "leaderboard" => "home#leaderboard"

  resources :matches, only: [:index, :show] do
    resources :contests, only: :index
  end

  resources :contests, only: [:index, :show] do
    post :join, on: :member
  end
  get "contests/:contest_id/team/new" => "user_teams#new", as: :new_contest_team
  post "contests/:contest_id/team" => "user_teams#create", as: :contest_team

  resources :user_teams, only: [:index, :show]
  resource :wallet, only: :show, controller: "wallet"

  namespace :api do
    namespace :v1 do
      resources :matches, only: [:index, :show] do
        resources :contests, only: :index
      end
      resources :contests, only: :show
      resources :user_teams, only: :index
      resource :wallet, only: :show, controller: "wallet"
    end
  end
end
