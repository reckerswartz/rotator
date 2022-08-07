Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  post 'dashboard/connect_to_database', to: 'dashboard#connect_to_database'

  # Defines the root path route ("/")
  root "dashboard#index"

  # Defines the route for the rotate_vault_secret action
  post 'dashboard/rotate_vault_secret', to: 'dashboard#rotate_vault_secret'
end
