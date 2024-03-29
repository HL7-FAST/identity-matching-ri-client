class UDAPController < ApplicationController

  before_action :set_patient_server
  # before_action :ensure_root_cert
  before_action :set_authority, only: [:register]

  # GET /udap/start
  # follows PatientServerController#create to reset HTTP headers
  def start

    #@bearer_token = ENV.fetch('BEARER_TOKEN', 'No Token')
    #@client_id = ENV.fetch('CLIENT_ID', 'No Client Id')
    #@client_secret = ENV.fetch('CLIENT_SECRET', 'No Client Secret')
    #@identity_provider = ENV.fetch('IDENTITY_PROVIDER', 'No UDAP Identity Provider URL')
    #@trusted_cert_pem = Certificate.x509.to_pem

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

  # GET /udap/register
  # Runs UDAP dynamic client registration on patient server
  def register
    begin
        asponse = RestClient.get(@patient_server.join('.well-known', 'udap'))
        @udap_metadata = JSON.parse(asponse.body)
    rescue Exception => e
        redirect_to udap_start_path and return
    end

    # TODO: check other udap metadata requirements
    # I guess client app could check x5c to verify a CA, but this is not in the spec for client

    software_statement = {
        'iss' => "https://test.healthtogo.me/udap-sandbox/mitre", #root_url,
        'sub' => "https://test.healthtogo.me/udap-sandbox/mitre", # root_url,
        'aud' => @udap_metadata['registration_endpoint'],
        'iat' => (now = Time.now).to_i,
        'exp' => (now + 5 * 60).to_i, # exp in 5 mins
        'jti' => SecureRandom.uuid,
        'client_name' => 'Identity Matching RI Client',
        'logo_uri' => image_uri('fast_logo_2022_sm.png'),
        'redirect_uris' => [ udap_redirect_url ],
        'grant_types' => ['authorization_code'], # blank array option would cancel registration
        'response_types' => ['code'],
        'token_endpoint_auth_method' => 'private_key_jwt',
        'scope' => 'udap */*'
    }

    ## Using self-signed cert to build end-entity certificate
    # root_cert = Authority.find_by!({name: "Self-Signed Certificate Authority"})

    # private_key = OpenSSL::PKey::RSA.new(2048) # TODO: save private key?
    # public_key = private_key.public_key
    # cert = OpenSSL::X509::Certificate.new
    # cert.version = 2
    # cert.serial = Random.rand(100)
    # cert.subject = OpenSSL::X509::Name.parse("/CN=Identity Matching RI Client/O=MITRE/C=US")
    # cert.public_key = public_key
    # cert.issuer = root_cert.subject
    # cert.not_before = now
    # cert.not_after = now + 60 * 60 * 24 * 365 # exp in 1 year
    # cert.sign(private_key, OpenSSL::Digest::SHA256.new)
    # ef = OpenSSL::X509::ExtensionFactory.new
    # ef.subject_certificate = cert
    # ef.issuer_certificate = root_cert
    # cert.add_extension(ef.create_extension("keyUsage","digitalSignature", true))
    # cert.add_extension(ef.create_extension("subjectKeyIdentifier","hash",false))
    # cert.add_extension(ef.create_extension("subjectAltName", "DNS:https://fhir-secid-client.herokuapp.com"))

    # cert_chain = [ Base64.encode64(cert.to_der), Base64.encode64(root_cert.to_der) ]
    # @jwt = JWT.encode(software_statement, private_key, 'RS256', header_fields = {'x5c' => cert_chain}) # signed!

    cert_chain = @authority.x509_chain.map { |x509_cert| Base64.encode64(x509_cert.to_der) }
    @jwt = JWT.encode(software_statement, @authority.private_key, 'RS256', header_fields = {'x5c' => cert_chain}) # signed!

    Rails.logger.debug "==== Signed Software Statement ===="
    Rails.logger.debug @jwt
    Rails.logger.debug "==================================="

    begin
        bsponse = RestClient.post( @udap_metadata['registration_endpoint'],
                                   {
                                       'software_statement' => @jwt,
                                       # 'certifications' => [], # optional
                                       'udap' => '1'
                                   }.to_json,
                                   { 'Content-Type' => 'application/json' }
                                  );
    rescue RestClient::ExceptionWithResponse => e
        bsponse = e.response
        unless e.response&.code == 400 # proper udap error response - handled below
            redirect_to(root_url, alert: "Client registration failed: #{e}") and return
        end
    end

    # Rails.logger.debug "====== Registration Response ======="
    # Rails.logger.debug bsponse.body
    # Rails.logger.debug "===================================="

    begin
        registration = JSON.parse(bsponse.body)
    rescue Exception => e
        redirect_to(root_url, alert: "UDAP server returned invalid JSON: #{bsponse.body}") and return
    end

    if registration['error'] && registration['error_description'] # highly conformant error
        flash.alert = "UDAP registration failed - error: #{registration['error']} - description: #{registration['error_description']}"
    elsif registration['error'] # conformant error
        flash.alert = "UDAP registration failed - error: #{registration['error']}"
    elsif registration['client_id'] # success
        if bsponse.code != 201     # nonconformant success
            Rails.logger.warn "UDAP Registration seems to have succeeded but response was #{bsponse.code}, expected 201"
            flash.alert = "Warning: Registration success but response code should be 201 but client received #{bsponse.code}"
        end
        @client_id = registration['client_id']
        @patient_server.client_id = @client_id
        Rails.logger.error "Failed to save client id" unless @patient_server.save
        #ENV['client_id'] = @client_id
        flash.notice = "Client registration success (client_id set to: #{@client_id})"
    else  # nonconformant
        flash.alert = "UDAP registration response missing JSON keys - expected 'client_id' or 'error', got: #{registration}"
    end

    redirect_to root_url
  end

  # GET /udap/redirect
  def redirect
  end

  private
  def ensure_root_cert
    if Certificate.count == 0 then
      Certificate.create_self_signed_cert()
    end
  end

  def set_authority
    #Rails.logger.debug "SETTING AUTHORITY WITH ID #{params.to_s}"
    redirect_to(udap_start_url, alert: "Error: you must specify an authority from #{udap_start_url}") and return unless params.dig(:authority, :id)
    @authority = Authority.find(params[:authority][:id])
  end

  def image_uri(name)
    File.join(root_url, ActionController::Base.helpers.asset_url(name, type: :image))
  end
end
