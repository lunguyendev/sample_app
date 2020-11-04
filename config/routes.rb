Rails.application.routes.draw do
  root to: "static_pages#home"

  get "static_pages/home"
  get "help", to: "static_pages#help"

  get "/signup", to: "users#new"
  post "/signup", to: "users#create"
  resources :users do
    member do
      get :following, :followers
    end
  end
  resources :users, except: :delete

  get "/login", to: "sessions#new"
  post "/login", to: "sessions#create"
  delete "/logout", to: "sessions#destroy"
  resources :sessions, only: %i(new show create)

  resources :account_activations, only: :edit

  resources :password_resets, only: %i(new create edit update)

  resources :microposts, only: %i(index create destroy)

  resources :relationships, only: %i(create destroy)
end
