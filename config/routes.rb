Rails.application.routes.draw do
  devise_for :users
  root to: "suplementos#index"
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      resources :suplementos, only: [ :index ]
      resources :stores, only: [ :index, :show ]
    end
  end

  namespace :api do
    namespace :v2 do
      resources :suplementos, only: [ :index, :show ]
    end
  end

  resources :suplementos, only: [ :index ]
  resources :posts, only: [:index]
  namespace :suplementos do
    get "get_bitlink", to: 'get_bitlink' #get route, to controller
    get "create_bitlink", to: 'create_bitlink' #get route, to controller
  end
    
end
