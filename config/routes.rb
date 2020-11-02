Rails.application.routes.draw do
  root to: "static_pages#home"

  get "static_pages/home"
  get "help", to: "static_pages#help"

  get "/signup", to: "users#new"
  post "/signup", to: "users#create"
  resources :users, except: [:delete]

  get "/login", to: "sessions#new"
  post "/login", to: "sessions#create"
  delete "/logout", to: "sessions#destroy"
  resources :sessions, only: [:new, :show, :create]
end
