class IdentityMatchingRequestsController < ApplicationController
  before_action :set_patient_server
  before_action :set_identity_matching_request, only: %i[ show edit update destroy ]

  # GET /identity_matching_requests or /identity_matching_requests.json
  def index
    @identity_matching_requests = IdentityMatchingRequest.all
  end

  # GET /identity_matching_requests/1 or /identity_matching_requests/1.json
  def show
  end

  # GET /identity_matching_requests/new
  def new
    @identity_matching_request = IdentityMatchingRequest.new
  end

  # GET /identity_matching_requests/1/edit
  def edit
  end

  # POST /identity_matching_requests or /identity_matching_requests.json
  def create
    @identity_matching_request = IdentityMatchingRequest.new(identity_matching_request_params)
    respond_to do |format|
      if @identity_matching_request.save_and_send(@patient_server.endpoint)
		if @identity_matching_request.response_status >= 200 && @identity_matching_request.response_status < 400
          format.html { redirect_to identity_matching_request_url(@identity_matching_request), notice: "Patient matches found!" }
		else
          format.html { redirect_to identity_matching_request_url(@identity_matching_request), notice: "Identity match attempted, no patient found." }
		end
        #format.json { render :show, status: :created, location: @identity_matching_request }
      else
		flash.now.alert = "There was an error, please check below."
        format.html { render :new, status: :unprocessable_entity }
        #format.json { render json: @identity_matching_request.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /identity_matching_requests/1 or /identity_matching_requests/1.json
  def update
    respond_to do |format|
      if @identity_matching_request.update(identity_matching_request_params)
        format.html { redirect_to identity_matching_request_url(@identity_matching_request), notice: "Identity matching request was successfully updated." }
        format.json { render :show, status: :ok, location: @identity_matching_request }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @identity_matching_request.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /identity_matching_requests/1 or /identity_matching_requests/1.json
  def destroy
    @identity_matching_request.destroy

    respond_to do |format|
      format.html { redirect_to identity_matching_requests_url, notice: "Identity matching request was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  # GET /identity_matching_requests/example
  def example
	@payload = File.read(Rails.root.join('resources', 'example_match_parameter.json'));
	conn = Faraday.new(url: @patient_server.endpoint, headers: {'Content-Type' => 'application/fhir+json'}) do |faraday|
	  faraday.response :logger, nil, {bodies: true, log_level: :debug}
	  faraday.response :raise_error
	end
	begin
		@response = conn.post do |req| req.body = @payload end
		flash.now.notice = 'Identity matching success'
	rescue Exception => exception
		flash.now.alert = "Failed to query #{@paient_server.endpoint}"
		@response = exception.to_s
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_identity_matching_request
      @identity_matching_request = IdentityMatchingRequest.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def identity_matching_request_params
      params.require(:identity_matching_request).permit(:full_name, :date_of_birth, :address_line1, :address_line2, :city, :state, :zipcode, :email, :mobile, :drivers_license, :gender)
    end

	# set @patient_server by session or by history or redirect to root
    def set_patient_server
	  @patient_server = PatientServer.find(session[:patient_server_id]) if session[:patient_server_id]
      @patient_server ||= PatientServer.last
	  redirect_to(root_url, {alert: "Please set a server to query."}) and return unless @patient_server
	end
end
