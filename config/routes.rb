Rails.application.routes.draw do

  root 'overviews#index'

  resources :pilots, only: [:index, :show, :update] do
    resources :squadrons, only: [:index]
    resource :image, only: [:show]
  end
  resources :ships, only: [:index, :show, :update] do
    resources :squadrons, only: [:index]
  end
  resources :ship_combos, only: [:index, :show, :update] do
    resources :squadrons, only: [:index]
  end
  resources :upgrades, only: [:index, :show, :update] do
    resources :squadrons, only: [:index]
    resource :image, only: [:show]
  end
  resources :conditions, only: [] do
    resource :image, only: [:show]
  end
  resources :squadrons, only: [:show]
  resource :about, only: [:show]

  resource :turning_test, only: [:show]


  get 'api/pilot/:id', to: 'api_pilot#show'
  get 'api/upgrade/:id', to: 'api_upgrade#show'

end
