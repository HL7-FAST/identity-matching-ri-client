Rails.application.routes.draw do
  root 'welcome#index'
  get 'welcome/index'
  get 'index', {controller: :welcome_controller, action: :index}

  get 'patient_server', {controller: :patient_server, action: :show}
  post 'patient_servers', {controller: :patient_server, action: :create}

  get 'identity_matchings/example'
  resources :identity_matchings

  get 'oauth2/start'
  get 'oauth2/restart'
  get 'oauth2/redirect'
  #post 'oauth2/register'

  get 'udap/start'
  get 'udap/register'

end
