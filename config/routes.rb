Rails.application.routes.draw do
  devise_for :users,
             path: "api/v1/auth",
             path_names: { sign_in: "login", sign_out: "logout", registration: "signup", password: "password" },
             controllers: {
               sessions: "api/v1/auth/sessions",
               registrations: "api/v1/auth/registrations",
               passwords: "api/v1/auth/passwords"
             },
             defaults: { format: :json }

  namespace :api do
    namespace :v1 do
      resource :profile, only: %i[show update]
      resources :resumes
      post "resumes/:id/download", to: "resumes#download"
      post "payments", to: "payments#create"
      post "payments/verify", to: "payments#verify"
      get "dashboard", to: "dashboard#show"
      get "admin", to: "admin#show"
      patch "admin/users/:id", to: "admin#update_user"
      patch "admin/users/:id/suspend", to: "admin#suspend_user"
      patch "admin/users/:id/activate", to: "admin#activate_user"
      patch "admin/users/:id/promote", to: "admin#promote_user"
      delete "admin/users/:id", to: "admin#destroy_user"
      patch "admin/settings", to: "admin#update_settings"
      get "admin/export/:kind", to: "admin#export"
      get "coming_soon", to: "coming_soon#show"
      resources :feature_interests, only: [:create]
      delete "feature_interests", to: "feature_interests#destroy"
      get "auth/me", to: "current_user#show"
    end
  end

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  root "frontend#show"
  get "*path", to: "frontend#show", constraints: ->(request) do
    !request.path.start_with?("/api", "/rails", "/up")
  end
end
