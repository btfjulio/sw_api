Rails.application.routes.draw do
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  devise_for :users
  

  get "blackfriday", to: "black_friday#index"

  require "sidekiq/web"
  authenticate :user, ->(user) { user.admin? } do
    mount Sidekiq::Web => '/sidekiq'
  end

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
      resources :base_suplements, only: [ :index, :show ]
      resources :brands, only: [ :index ]
      resources :categories, only: [ :index ]
    end
  end

  get "landing", to: 'pages#landing'

  resources :posts, only: [:index]
  
  resources :suplementos, only: [ :index ]
  namespace :suplementos do
    get "get_bitlink", to: 'get_bitlink' #get route, to controller
    get "create_bitlink", to: 'create_bitlink' #get route, to controller
  end

  resources :equipments, only: [ :index ]
  namespace :equipments do
    get "get_bitlink", to: 'get_bitlink' #get route, to controller
    get "create_bitlink", to: 'create_bitlink' #get route, to controller
  end
    
end
