class Oauth2Controller < ApplicationController

  before_action :set_patient_server
  around_action :set_client

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

=begin
	options = @client.get_oauth2_metadata_from_conformance
	Rails.logger.debug "SERVER OAUTH2:"
	Rails.logger.debug options
	
	if options.blank?
		options[:authorize_url] = "#{@patient_server.join('oauth2','authorize')}"
		options[:token_url] = "#{@patient_server.join('oauth','token')}"

		flash.alert = "Detected no oauth2 endpoints in server's compatability statement. You must add this to compatability statement. Defaulting to #{options}."
		Rails.logger.error "No OAuth2 endpoints found in compatability statement"
	end

	@client.set_oauth2_auth(ENV['CLIENT_ID'], ENV['CLIENT_SECRET'], options[:authorize_url], options[:token_url], @patient_server.base);
	flash.notice = "OAuth2 Success? #{client}"
	reply = @client.read_feed(FHIR::Patient)
	Rails.logger.debug reply.to_s
=end
	redirect_to root_url and return
  end

  def redirect
  end

  private

  def set_client
	@client = FHIR::Client.new(@patient_server.base)
	yield
  end

end
