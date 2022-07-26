class PatientServerController < ApplicationController

  before_action :set_patient_server, only: [:show]

  # POST /patient_servers
  def create
	@patient_server = PatientServer.find_or_create_by!(patient_server_params)
	session[:patient_server_id] = @patient_server.id
	flash.notice = "Patient server set to #{@patient_server.base}"

	if commit_param == 'Match Patient'
		redirect_to new_identity_matching_path
	elsif commit_param == 'Register (UDAP)'
		redirect_to udap_register_path
	elsif commit_param == 'Authorize (OAuth)'
		head 501 # TODO
	else # Metadata
		redirect_to patient_server_path
	end
  end

  # GET /patient_server
  def show
	begin
		@metadata = Faraday.get(@patient_server.join('metadata')).body
	rescue Exception => exception
		flash.now.alert = "An exception occurred"
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

  def commit_param
	puts "COMMIT PARAM: #{params.require(:commit)}"
	return params.require(:commit)
  end

end
