Rails.application.routes.draw do
  # =====================================
  # UniMatch Routes
  # =====================================

  # หน้าแรก
  root "pages#home"

  # Authentication
  get    "login",    to: "sessions#new",     as: :login
  post   "login",    to: "sessions#create"
  delete "logout",   to: "sessions#destroy", as: :logout
  get    "register", to: "registrations#new", as: :register
  post   "register", to: "registrations#create"

  # Profile
  get  "profile/edit", to: "profiles#edit",   as: :edit_profile
  patch "profile",     to: "profiles#update", as: :update_profile

  # Dashboard
  get "dashboard", to: "dashboard#show", as: :dashboard

  # Matching
  resources :matches, only: [:index] do
    member do
      post :icebreaker
      post :start_chat
    end
  end

  # Chat
  resources :chat_rooms, only: [:index, :show] do
    member do
      post :reveal_identity
      get :partner_profile
    end
    resources :messages, only: [:create]
    resources :reviews, only: [:create]
  end
  post "chat_rooms/ai", to: "chat_rooms#create_ai_room", as: :create_ai_chat

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check
end
