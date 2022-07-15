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
	puts "Made new object"
    respond_to do |format|
      if @identity_matching_request.save
		puts "Saved object"
		if @identity_matching_request.send(session[:base]) == 200
		  puts "Sent request, got OK"
          format.html { redirect_to identity_matching_request_url(@identity_matching_request), notice: "Patient match found!" }
		else
		  puts "Sent request, got 4xx"
          format.html { redirect_to identity_matching_request_url(@identity_matching_request), notice: "Identity match attempted, no patient found." }
          #format.json { render :show, status: :created, location: @identity_matching_request }
		end
      else
		puts "Failed to save object"
		flash.now.alert = "Invalid input, please double check."
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

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_identity_matching_request
      @identity_matching_request = IdentityMatchingRequest.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def identity_matching_request_params
      params.require(:identity_matching_request).permit(:full_name, :date_of_birth, :address_line1, :address_line2, :city, :state, :zipcode, :email, :mobile, :response_status, :response_json)
    end

	# set @patient_server or redirect to root
    def set_patient_server
	  @patient_server = session[:patient_server]
      @patient_server ||= PatientServer.last
	  redirect_to(root_url, {alert: "Please set a server to query."}) and return unless @patient_server
	end
end
