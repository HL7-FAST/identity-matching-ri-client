Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

  root 'welcome#index'

  get 'welcome/index'
  post 'patient_servers', {controller: :patient_server, action: :create}

end
