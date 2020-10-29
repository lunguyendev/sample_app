Rails.application.routes.draw do
  root to: "static_pages#home"

  get "static_pages/home"
  get "static_pages/help"

  get "/signup", to: "users#new"
  post "/signup", to: "users#create"
  resources :users, only: [:new, :show, :create]
end
