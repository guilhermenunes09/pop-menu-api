Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      resources :restaurants do
        collection do
          post :import_json
        end

        resources :menus do
          post :add_menu_item, on: :member
          delete :remove_menu_item, on: :member
        end

        resources :menu_items, only: [ :index, :show, :create, :update, :destroy ]
      end
    end
  end
end
