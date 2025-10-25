Rails.application.routes.draw do
  authenticated :user do
    root to: "homes#index", as: :authenticated_root
  end

  unauthenticated do
    root to: "pages#top", as: :unauthenticated_root
  end

  devise_for :users, controllers: {
    registrations: "users/registrations",
    omniauth_callbacks: "users/omniauth_callbacks"
  }

  get "top", to: "pages#top"
  get "diary/writing_tips", to: "pages#diary_writing_tips"
  get "home", to: "homes#index"
  get "privacy_policy", to: "pages#privacy_policy"
  get "terms_of_service", to: "pages#terms_of_service"

  resources :diaries do
    collection do
      get :autocomplete
    end

    member do
      get :ai_comment
    end
  end

  get "my_diaries", to: "diaries#my_diaries", as: :my_diaries
  get "public_diaries", to: "diaries#public_diaries", as: :public_diaries

  resources :users, only: %i[show]
  resource :notification_setting, only: %i[edit update]



  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Defines the root path route ("/")
  # root "posts#index"
end
