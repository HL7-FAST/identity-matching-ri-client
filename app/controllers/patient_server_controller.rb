class PatientServerController < ApplicationController

  # POST /patient_servers
  def create
	@patient_server = PatientServer.find_or_create_by!(patient_server_params)
	session[:base] = @patient_server.base
	redirect_to new_identity_matching_request_path, notice: "Patient server set to #{session[:base]}."
  end

  private

  def patient_server_params
	params.require(:patient_server).permit([:base])
	# TODO: normalize URL base
  end

end
