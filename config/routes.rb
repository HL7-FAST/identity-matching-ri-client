Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

  root 'welcome#index'

  get 'welcome/index'
  get 'patient_server', {controller: :patient_server, action: :show}
  post 'patient_servers', {controller: :patient_server, action: :create}
  get 'identity_matching_requests/example'
  resources :identity_matching_requests

end
