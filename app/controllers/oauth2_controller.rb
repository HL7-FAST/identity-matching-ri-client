
# Open class for debugging
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

  # GET /oauth2/start
  # follows PatientServerController#create to reset HTTP headers
  def start
  end

  # POST /oauth2/register
  # preform client registration as specified in security spec
  def register
	payload = {
		iss: "#{root_url}",
		sub: "client_id?",
		aud: "#{@patient_server.join('oauth','register')}", # TODO: fetch from capability statement
		#exp: (now + 4.5).to_i, # TODO
		iat: DateTime.now.to_i,
		jti: SecureRandom.base58,
		client_name: "encode.rb",
		redirect_uris: "[\"#{oauth2_redirect_url}\"]",
		contacts: '["mailto:shaumikashraf@mitre.org"]',
		logo_uri: "https://hl7.org/fhir/assets/images/fhir-logo.png",
		grant_types: "authorization_code",
		response_types: '["code"]',
		token_endpoint_auth_method: "private_key-jwt",
		scope: "system/Patient.read system/Observation.read"
	}

	token = JWT.encode(payload, nil, 'none'). # TODO: load certificate chan and use x5c algorithm
	resposne = RestClient.post(@patient_server.join('oauth','register'), payload=token, nil); # TODO

	# TODO check response

	redirct_to :root_ril
  end

  # GET /oauth2/restart
  # initiate actual oauth2 protocol
  def restart
	options = @client.get_oauth2_metadata_from_conformance
	Rails.logger.debug "SERVER OAUTH2 POINTS:"
	Rails.logger.debug options
	
	if options.blank?
		options[:authorize_url] = "#{@patient_server.join('oauth','authorize')}"
		options[:token_url] = "#{@patient_server.join('oauth','token')}"

		flash.alert = "Detected no oauth2 endpoints in server's compatability statement. You must add this to compatability statement. Defaulting to #{options}."
		Rails.logger.error "No OAuth2 endpoints found in compatability statement"
	end

	Rails.logger.debug "AUTHORIZATION URL"
    @auth_params = {:response_type => 'code', :client_id => ENV["CLIENT_ID"], :redirect_uri => oauth2_redirect_url, :state => SecureRandom.uuid, :aud => @patient_server.base }
    @authorize_url = options[:authorize_url] + "?" + @auth_params.to_query
	Rails.logger.debug @authorize_url
	session[:authorize_url] = @authorize_url
	
	#response.headers.delete_if! { |header| header.upcase == 'X-CSRF-TOKEN' } # CORS policy rejects request with headers not in Access-Control-Allow-Headers, and CSRF protection is done by state param

    redirect_to(@authorize_url, {allow_other_host: true}) and return
	#render :debug
  end

  # GET /oauth2/redirect
  # oauth2 redirect endpoint
  def redirect
	Rails.logger.debug "HIT CLIENT REDIRECT"

    @code = params[:code]
    if @code.present?
		@token_params = {:grant_type => 'authorization_code', :code => @code, :redirect_uri => ENV["REDIRECT_URI"], :client_id => ENV["CLIENT_ID"]}
        @token_url = @patient_server.join('oauth', 'token') # HARDCODED - TODO: get from metadata
		Rails.logger.debug "GETTING TOKEN"
		Rails.logger.debug @token_url
		Rails.logger.debug @token_params

        @response = RestClient.post(@token_url, @token_params, {'accept' => 'application/fhir+json'});
        puts @response.body

        @token = JSON.parse(@response.body)["access_token"]

        @client = FHIR::Client.new(@patient_server.base)
        @client.set_bearer_token(@token)
    else
		Rails.logger.error "NO CODE"
   	end

	render :debug
  end

  private

  def set_client
	@client = FHIR::Client.new(@patient_server.base)
	yield
  end

end
