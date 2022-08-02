class Oauth2Controller < ApplicationController

  before_action :set_patient_server
  around_action :set_client

  def start
=begin
	metadata = JSON.parse( RestClient.get(@patient_server.join('metadata')).body )
#	security_services = metadata.dig('rest', 0, 'security', 'service')
#	oauth_idx = security_services.find_index {|x| x.dig('coding', 0, 'code') in ["SMART-on-FHIR", "OAuth"] }
#	raise StandardError.new("Server does not have oauth2 in compatablity statement") unless oauth_idx

	security_extensions = metadata.dig('rest', 0, 'security', 'extension');
	oauth_idx = security_extensions.find_index {|x| x['url'] == "http://fhir-registry.smarthealthit.org/StructureDefinition/oauth-uris"}
	

	@state = SecureRandom.base58(6)
	session[:oauth2_state] = @state

	@client_id = ENV['CLIENT_ID'] || raise StandardError.new("CLIENT_ID must be set in ENV")
	@client_secret = ENV['CLIENT_SECRET'] || raise StandardError.new("CLIENT_SECRET must be set in ENV")
	
	@authorization_url = URI.escape("")
=end

=begin
	# Rack-OAuth2 gem
	@oauth2_client = Rack::OAuth2::Client.new(
	  identifier: ENV['CLIENT_ID'],
	  secret: ENV['CLIENT_SECRET'],
	  redirect_uri: oauth2_redirect_url
	  #host: @patient_server.base
	);
	authorization_url = @oauth2_client.authorization_uri(state: @state);
	redirect_to authorization_url and return
=end

#begin
	# fhir_client gem
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
	redirect_to root_url and return
#end
  end

  def redirect
	if params[:state] != session[:oauth2_state]
	  flash.now.alert = "OAuth2 state does not match!"
	  render :error, status: 400
	end

	@token = client.access_token!
	flash.notice = "OAuth2 success - obtained token #{@token}"
	ENV['BEARER_TOKEN'] = @token
	
	redirect_to root_url
  end

  private

  def set_client
	@client = FHIR::Client.new(@patient_server.base)
	yield
  end

end
