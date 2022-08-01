class Oauth2Controller < ApplicationController

  before_action :set_patient_server

  def start
	@state = SecureRandom.base58(6)
	session[:oauth2_state] = @state

	@oauth2_client = Rack::OAuth2::Client.new(
	  identifier: ENV['CLIENT_ID'],
	  secret: ENV['CLIENT_SECRET'],
	  redirect_uri: oauth2_redirect_url,
	  host: @patient_server.base
	);

	authorization_url = @oauth2_client.authorization_uri(state: @state);
	redirect_to authorization_url and return	
  end

  def redirect
  end
end
