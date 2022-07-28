Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  post 'dashboard/connect_to_database', to: 'dashboard#connect_to_database'

  # Defines the root path route ("/")
  root "dashboard#index"
end
