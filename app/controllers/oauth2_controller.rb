class FHIR::Client

    # Set the client to use OpenID Connect OAuth2 Authentication
    # client -- client id
    # secret -- client secret
    # authorize_path -- absolute path of authorization endpoint
    # token_path -- absolute path of token endpoint
    def set_oauth2_auth(client, secret, authorize_path, token_path, site = nil)
      FHIR.logger.info 'Configuring the client to use OpenID Connect OAuth2 authentication.'
	  Rails.logger.debug "HIJACKED"

      @use_oauth2_auth = true
      @use_basic_auth = false
      @security_headers = {}
      options = {
        site: site || @base_service_url,
        authorize_url: authorize_path,
        token_url: token_path,
        raise_errors: true
      }
      client = OAuth2::Client.new(client, secret, options)
      client.connection.proxy(proxy) unless proxy.nil?
      @client = client.client_credentials.get_token
    end

end

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
		options[:authorize_url] = "#{@patient_server.join('oauth','authorize')}"
		options[:token_url] = "#{@patient_server.join('oauth','token')}"

		flash.alert = "Detected no oauth2 endpoints in server's compatability statement. You must add this to compatability statement. Defaulting to #{options}."
		Rails.logger.error "No OAuth2 endpoints found in compatability statement"
	end

	Rails.logger.debug "BUILDING URL"
    @params = {:response_type => 'code', :client_id => ENV["CLIENT_ID"], :redirect_uri => oauth2_redirect_url, :state => SecureRandom.uuid, :aud => @patient_server.base }
    @authorize_url = options[:authorize_url] + "?" + @params.to_query
	Rails.logger.debug @authorize_url
    redirect_to(@authorize_url, {allow_other_host: true}) and return

	#flash.notice = "OAuth2 Success? #{@client.to_json}"
	#redirect_to root_url and return
  end

  def redirect
	 Rails.logger.debug "HIT CLIENT REDIRECT"

     @code = params[:code]
     if @code.present?
        @token_params = {:grant_type => 'authorization_code', :code => @code, :redirect_uri => ENV["REDIRECT_URI"], :client_id => ENV["CLIENT_ID"]}
        @token_url = @patient_server.join('oauth', 'token') # HARDCODED - TODO: get from metadata
        @response = RestClient.post(@token_url, @token_params, {'accept' => 'application/fhir+json'});
        puts @response.body

        @token = JSON.parse(@response.body)["access_token"]

        #@patient_server.base = Rails.cache.read("base_server_url")

        @client = FHIR::Client.new(@patient_server.base)
        @client.set_bearer_token(@token)
     else
		Rails.logger.error "NO CODE"
   	 end

=begin
	if params[:state] != session[:oauth2_state]
	  flash.now.alert = "OAuth2 state does not match!"
	  render :error, status: 400
	end

	@token = client.access_token!
	flash.notice = "OAuth2 success - obtained token #{@token}"
	ENV['BEARER_TOKEN'] = @token
	
	redirect_to root_url
=end

	render :error
  end

  private

  def set_client
	@client = FHIR::Client.new(@patient_server.base)
	yield
  end

end
