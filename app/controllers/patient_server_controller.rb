class PatientServerController < ApplicationController

  before_action :set_patient_server, only: [:show]

  # POST /patient_servers
  def create
	@patient_server = PatientServer.find_or_create_by!(patient_server_params)
	session[:patient_server_id] = @patient_server.id
	redirect_to new_identity_matching_request_path, notice: "Patient server set to #{@patient_server.base}."
  end

  # GET /patient_server
  def show
	begin
		@metadata = Faraday.get(@patient_server.join('metadata')).body
	rescue Exception => exception
		@metadata = exception.to_json
	end
  end

  private

  def patient_server_params
	sanitized_params = params.require(:patient_server).permit([:base])

    # normalize URL
	url = sanitized_params[:base]
	url = 'http://' + url unless url.starts_with? /https?:\/\//

	# TODO: normalize URL better

	sanitized_params[:base] = url
	return sanitized_params
  end

end
