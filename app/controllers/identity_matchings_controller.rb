class IdentityMatchingsController < ApplicationController
  before_action :set_patient_server
  before_action :set_identity_matching, only: %i[ show edit update destroy ]

  # GET /identity_matchings or /identity_matching.json
  def index
    @identity_matchings = IdentityMatching.all
  end

  # GET /identity_matching/1 or /identity_matching/1.json
  def show
  end

  # GET /identity_matching/new
  def new
    @identity_matching = IdentityMatching.new
  end

  # GET /identity_matching/1/edit
  def edit
  end

  # POST /identity_matchings or /identity_matchings.json
  def create
    @identity_matching = IdentityMatching.new(identity_matching_params)
    respond_to do |format|
      if @identity_matching.save_and_send(@patient_server.endpoint)
		# TODO: identify a better criteria to distinguish between patient found and patient not found
		if @identity_matching.response_json && @identity_matching.response_json.fetch('total', 0) > 0
          format.html { redirect_to identity_matching_url(@identity_matching), notice: "Patient matches found!" }
		else
          format.html { redirect_to identity_matching_url(@identity_matching), notice: "Identity match attempted, no patients found." }
		end
        #format.json { render :show, status: :created, location: @identity_matching }
      else
		flash.now.alert = "There was an error, please check below."
        format.html { render :new, status: :unprocessable_entity }
        #format.json { render json: @identity_matching.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /identity_matching/1 or /identity_matching/1.json
  def update
    respond_to do |format|
      if @identity_matching.update(identity_matching_params) && @identity_matching.save_and_send(@patient_server.endpoint)
		if @identity_matching.response_json && @identity_matching.response_json.fetch('total', 0) > 0
          format.html { redirect_to identity_matching_url(@identity_matching), notice: "Identity matching request was successfully updated." }
		else
          format.html { redirect_to identity_matching_url(@identity_matching), notice: "Identity match updated, no patients found." }
		end
        #format.json { render :show, status: :ok, location: @identity_matching }
      else
        format.html { render :edit, status: :unprocessable_entity }
        #format.json { render json: @identity_matching.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /identity_matching/1 or /identity_matching/1.json
  def destroy
    @identity_matching.destroy

    respond_to do |format|
      format.html { redirect_to identity_matchings_url, notice: "Patient identity record deleted." }
      format.json { head :no_content }
    end
  end

  # GET /identity_matching/example
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
    def set_identity_matching
      @identity_matching = IdentityMatching.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def identity_matching_params
      params.require(:identity_matching).permit(:full_name, :date_of_birth, :address_line1, :address_line2, :city, :state, :zipcode, :email, :mobile, :drivers_license, :gender, :national_insurance_payer_identifier)
    end

end
