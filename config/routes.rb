Rails.application.routes.draw do
  # Short URL redirects (must be public)
  get "s/:token", to: "short_urls#show", as: :short_url

  # Devise routes
  devise_for :users, controllers: {
    omniauth_callbacks: "users/omniauth_callbacks",
    registrations: "users/registrations"
  }

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # PWA files
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Root routes
  authenticated :user do
    root "dashboards#show", as: :authenticated_root
  end
  root "pages#home"

  # Marketing/Static pages
  get "pricing", to: "pages#pricing"
  get "about", to: "pages#about"
  get "contact", to: "pages#contact"

  # Authenticated user routes
  authenticate :user do
    resource :dashboard, only: [:show]

    resources :credentials do
      collection do
        get :bulk_new
        post :bulk_create
      end
      member do
        post :extract # Re-trigger AI extraction
        get :download
      end
      resources :alerts, only: [:create, :destroy], shallow: true
      resources :share_links, only: [:create], shallow: true
    end

    resources :alerts, only: [:index]
    resources :notifications, only: [:index, :show]

    # Account settings
    namespace :account do
      resource :profile, only: [:show, :update] do
        post :verify_npi, on: :collection
      end
      resource :subscription, only: [:show, :update]
      resources :payments, only: [:index]
      resources :support_messages, only: [:index, :show, :new, :create]
      post 'checkout', to: 'checkout#create'
    end
  end

  # Stripe webhooks (must be public, outside authentication)
  namespace :webhooks do
    post 'stripe', to: 'stripe#create'
  end

  # Public share link access
  get "share/:token", to: "share_links#show", as: :share

  # API routes
  namespace :api do
    post "npi_lookups/lookup", to: "npi_lookups#lookup", as: :npi_lookup
  end

  # Admin routes
  namespace :admin do
    root "dashboard#index"

    resource :theme_settings, only: [:edit, :update] do
      post :apply_defaults, on: :collection
    end
    resources :message_usage, only: [:index]
    resources :integrations, only: [:index]

    resources :support_messages, only: [:index, :show] do
      member do
        post :reply
      end
    end

    resources :users do
      member do
        patch :toggle_admin
        post :send_password_reset
      end
    end

    resources :alert_types
    resources :tags
    resource :settings, only: [:show, :update]
    resources :email_templates
    resources :llm_requests, only: [:index, :show]
    resources :workflows
    resources :ai_models do
      member do
        post :set_default
      end
    end

    get "reports", to: "reports#index"
    get "reports/users", to: "reports#users"
    get "reports/credentials", to: "reports#credentials"
    get "reports/llm_usage", to: "reports#llm_usage"
  end

  # Sidekiq Web UI (admin only)
  require 'sidekiq/web'
  authenticate :user, ->(user) { user.admin? } do
    mount Sidekiq::Web => '/admin/sidekiq'
  end

  # Email preview in development
  if Rails.env.development?
    if defined?(LetterOpenerWeb)
      mount LetterOpenerWeb::Engine, at: "/letter_opener"
    end
  end
end
