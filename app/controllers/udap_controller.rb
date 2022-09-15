class UDAPController < ApplicationController

  before_action :set_patient_server

  # GET /udap/start
  # follows PatientServerController#create to reset HTTP headers
  def start

    @bearer_token = ENV.fetch('BEARER_TOKEN', 'No Token')
    @client_id = ENV.fetch('CLIENT_ID', 'No Client Id')
    @client_secret = ENV.fetch('CLIENT_SECRET', 'No Client Secret')
    @identity_provider = ENV.fetch('IDENTITY_PROVIDER', 'No UDAP Identity Provider URL')

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
        response = RestClient.get(@patient_server.join('.well-known', 'udap'))
        @udap_metadata = JSON.parse(response.body)
    rescue Exception => e
        redirect_to udap_start_path and return
    end

    # TODO: check other udap metadata requirements
    # I guess client app could check x5c to verify a CA, but this is not in the spec for client

    software_statement = {
        'iss' => 'http://localhost:3000', # TODO: fetch dynamically
        'sub' => 'http://localhost:3000',
        'aud' => @udap_metadata['authorization_endpoint'],
        'iat' => (now = Time.now).to_i,
        'exp' => (now + 5 * 60).to_i, # exp in 5 mins
        'jti' => Random.rand(10**6),
        'client_name' => 'trying udap', # TODO: better name or recv as input
        'redirect_uris' => [ udap_redirect_url ],
        'grant_types' => ['authorization_code'],
        'response_types' => ['code'],
        'token_endpoint_auth_method' => 'private_key_jwt',
        'scope' => 'udap */*' # TODO: get scope from input?
    }

    # TODO: use an uploaded cert instead of self signed
    root_cert = self_signed_x509_cert()

    private_key = OpenSSL::PKey::RSA.new(2048) # TODO: save private key?
    public_key = private_key.public_key
    cert = OpenSSL::X509::Certificate.new
    cert.version = 2
    cert.serial = Random.rand(100)
    cert.subject = OpenSSL::X509::Name.parse "/DC=udap-example/CN=US"
    cert.public_key = public_key
    cert.issuer = root_cert.subject
    cert.not_before = now
    cert.not_after = now + 60 * 60 * 24 * 365 # exp in 1 year
    cert.sign(private_key, OpenSSL::Digest::SHA256.new)
    # TODO: cert extensions

    cert_chain = [ Base64.encode64(cert.to_der), Base64.encode64(root_cert.to_der) ]
    @jwt = JWT.encode(software_statement, private_key, 'RS256', header_fields = {'x5c' => cert_chain}) # signed!

    response = RestClient.post( @udap_metadata['registration_endpoint'], payload = {
                                                                        'software_statement' => @jwt,
                                                                        # 'certifications' => [], # optional
                                                                        'udap' => '1'
                                                                        } );

    puts "================="
    puts response.body
    puts "================="
    # FIXME: udap authorization server times out?
    # TODO: check for and save client id

    redirect_to root_url, notice: "Client registration success" # TODO: better ending
  end

  # GET /udap/redirect
  def redirect
  end

  private
  def self_signed_x509_cert()
    private_key = OpenSSL::PKey::RSA.new(2048)
    public_key = private_key.public_key
    subject = "/C=US/CN=Test"

    cert = OpenSSL::X509::Certificate.new
    cert.subject = cert.issuer = OpenSSL::X509::Name.parse(subject)
    cert.not_before = Time.now
    cert.not_after = Time.now + 365 * 24 * 60 * 60
    cert.public_key = public_key
    cert.serial = 0 # In production, this should be a secure random unique positive integer
    cert.version = 2

    ef = OpenSSL::X509::ExtensionFactory.new
    ef.subject_certificate = cert
    ef.issuer_certificate = cert

    # TODO: double check extensions
    cert.extensions = [
      ef.create_extension("basicConstraints","CA:TRUE", true),
      ef.create_extension("subjectKeyIdentifier", "hash"),
      # ef.create_extension("keyUsage", "cRLSign,keyCertSign", true),
    ]
    cert.add_extension ef.create_extension("authorityKeyIdentifier",
                                           "keyid:always,issuer:always")

    cert.sign private_key, OpenSSL::Digest::SHA256.new

    return cert
  end

end
