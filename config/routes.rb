Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root "projects#index"
  resources :projects, only: %i(index show create new) do
    resources :sheets, only: %i(create show)
    resources :metrics, only: %i(index)
  end
  resources :sheets, only: %i(edit update destroy) do
    resources :sections, only: %i(create)
    resources :entries, only: %i(create update)
  end
  resources :sections, only: %i(show edit update destroy) do
    resources :rows, only: %i(new)
    resources :metrics, only: %i(new create) do
      resources :rows, only: %i(create)
    end
  end
  resources :rows, only: %i(show destroy)
  resources :metrics, only: %i(edit update) do
    resources :formulas, only: %i(create)
  end
  resources :formulas, only: %i(update destroy)
  patch "sheets/:id/sort", to: "sheets#sort"
  patch "sections/:id/sort", to: "sections#sort"
  patch "projects/:sheet_id/:metric_id/:period_id", to: "projects#input", as: :input
end
