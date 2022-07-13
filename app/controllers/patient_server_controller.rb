class PatientServerController < ApplicationController

  # POST /patient_servers
  def create
	@patient_server = PatientServer.find_or_create_by!(patient_server_params)
	session[:base] = @patient_server.base
	redirect_to '/', notice: "Patient server set to #{session[:base]}."
  end

  private

  def patient_server_params
	params.require(:patient_server).permit([:base])
  end

end
