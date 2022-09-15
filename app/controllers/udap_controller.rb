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
	redirect_to root_url, alert: "UDAP dynamic client registration is still under development..."
  end

end
