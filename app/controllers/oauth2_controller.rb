class Oauth2Controller < ApplicationController

  before_action :set_patient_server
  around_action :set_client

  # GET /oauth2/start
  # follows PatientServerController#create to reset HTTP headers
  def start

    @bearer_token = ENV.fetch('BEARER_TOKEN', 'No Token')
    @patient_server.client_id ||= ENV.fetch('CLIENT_ID', 'No Client Id')
    @patient_server.identity_provider ||= ENV.fetch('IDENTITY_PROVIDER', 'No UDAP Identity Provider URL')

    begin
        response = RestClient.get(@patient_server.join('.well-known', 'udap'))
        @udap_metadata = JSON.parse(response.body)
    rescue RestClient::ExceptionWithResponse => e
        response = e.response
        flash.now.alert = "#{@patient_server} does not support UDAP (missing /.well-known/udap)."
    rescue Exception => e
        flash.now.alert = "#{@patient_server.join('.well-known','udap')} is not valid JSON"
    ensure
        @udap_metadata ||= {"error" => e}
    end


  end

  # POST /oauth2/register
  ## IGNORE THIS ACTION - registration handled by udap controller
  # def register
  #   @identity_provider = ENV.fetch('IDENTITY_PROVIDER', 'No UDAP Identity Provider URL')
  #
  #   rsa_private_key = OpenSSL::PKey::RSA.generate 2048
  #   rsa_public_key = rsa_private_key.public_key
  #
  # payload = {
  # 	iss: "#{root_url}",
  #       idp: @identity_provider,
  # 	sub: "client_id?", # TODO
  # 	aud: @patient_server.join('oauth','register'), # TODO: fetch from capability statement
  # 	#exp: (now + 4.5).to_i, # TODO
  # 	iat: DateTime.now.to_i,
  # 	jti: SecureRandom.base58,
  # 	client_name: "encode.rb", # TODO
  # 	redirect_uris: "[\"#{oauth2_redirect_url}\"]",
  # 	contacts: '["mailto:shaumikashraf@mitre.org"]',
  # 	logo_uri: "https://hl7.org/fhir/assets/images/fhir-logo.png",
  # 	grant_types: "authorization_code",
  # 	response_types: '["code"]',
  # 	token_endpoint_auth_method: "private_key-jwt",
  # 	scope: "system/Patient.read system/Observation.read"
  # }
  #
  #   x509_cert_chain = [ self_signed_x509_cert(rsa_private_key, rsa_public_key) ] # TODO: load PEM cert chain option
  #   token = JWT.encode(payload, rsa_private_key, 'RS256', { x5c: "#{x509_cert_chain}" })
  #
  #   begin
  #     response = RestClient.post(@patient_server.join('oauth','register'), payload=token, nil)
  #   rescue Exception => e
  #       response = e.response
  #       flash.alert = "Failed to send request to #{@patient_server.join('oauth','register')}"
  #   end
  #
  #   Rails.logger.debug "== OAUTH2 REGISTER RESPONSE =="
  #   Rails.logger.debug response.to_json
  #   Rails.logger.debug "=============================="
  #
  #   redirect_to root_url
  # end

  # GET /oauth2/restart
  # initiate actual oauth2 protocol - authorization code flow
  def restart
    @patient_server.update(patient_server_params)

    @identity_provider = @patient_server.identity_provider
    @identity_provider ||= 'No UDAP Identity Provider URL'
	options = @fhir_client.get_oauth2_metadata_from_conformance

	if options.blank?
		options[:authorize_url] = @patient_server.join('oauth','authorize')
		options[:token_url] = @patient_server.join('oauth','token')

		flash.alert = "Detected no oauth2 endpoints in server's compatability statement. You must add this to compatability statement. Defaulting to #{options}."
		Rails.logger.error "No OAuth2 endpoints found in compatability statement"
	end
    session[:token_url] = options[:token_url]

    session[:state] = SecureRandom.uuid;
    @auth_params = {
        :response_type => 'code',
        :client_id => @patient_server.client_id,
        :redirect_uri => oauth2_redirect_url,
        :state => session[:state],
        :aud => @patient_server.base,
        :idp => @patient_server.identity_provider
    }

    @authorize_url = options[:authorize_url] + "?" + @auth_params.to_query
	#Rails.logger.debug "== AUTHORIZATION URL =="
	#Rails.logger.debug @authorize_url
	#Rails.logger.debug "======================="

	session[:authorize_url] = @authorize_url

    redirect_to @authorize_url, allow_other_host: true
  end

  # GET /oauth2/redirect
  # oauth2 redirect endpoint (for both authorize and token)
  def redirect
	Rails.logger.debug "HIT CLIENT REDIRECT"

    @code = params[:code]
    @access_token = params[:access_token]

    if @code.present?
        @state = params[:state]
        if @state != session[:state]
            Rails.logger.error("Oauth2 state does not match!")
            Rails.logger.error("Received state: #{@state}")
            Rails.logger.error("Expected state: #{session[:state]}")
            flash.now.alert = "Oauth state does not match, received: #{@state}, expected: #{session[:state]}"
        end

		@token_params = {
            :grant_type => 'authorization_code',
            :code => @code,
            :redirect_uri => oauth2_redirect_url,
            :client_id => ENV["CLIENT_ID"],
            :client_secret => ENV["CLIENT_SECRET"]
        }
        @token_url = session[:token_url]
		#Rails.logger.debug "== GETTING TOKEN =="
		#Rails.logger.debug @token_url
		#Rails.logger.debug @token_params
		#Rails.logger.debug "==================="

        begin
            @response = RestClient.post(@token_url, @token_params);
            #Rails.logger.debug "== POST /token =="
            #Rails.logger.debug @response.body
            #Rails.logger.debug "================="
        rescue RestClient::ExceptionWithResponse => e
            flash.now.alert = "Oauth server could not handle token request. Error: #{e}"
            Rails.logger.error "Failed POST #{@token_url}, error #{e}"
            render :debug and return
        end

        @token = JSON.parse(@response.body)["access_token"]
        session[:access_token] = @token
        flash.now.notice = "Obtained access token!"

        @fhir_client = FHIR::Client.new(@patient_server.base)
        @fhir_client.set_bearer_token(@token)
    else
		Rails.logger.error "oauth2/redirect/ endpoint triggered but missing code parameter"
        flash.now.alert = "oauth2/redirect/ endpoint triggered without code parameter, params: #{params}"
        render(:debug, status: 400) and return
   	end

	# renders app/views/oauth2/redirect.html.erb with success message
  end

  private
  def patient_server_params
    params.require( :patient_server ).permit(:client_id, :identity_provider)
  end

  def set_client
	@fhir_client = FHIR::Client.new(@patient_server.base)
	yield
  end


end
