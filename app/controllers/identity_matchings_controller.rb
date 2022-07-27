class IdentityMatchingsController < ApplicationController
  before_action :set_patient_server
  before_action :set_identity_matching, only: %i[ show edit update destroy ]

  # GET /identity_matchings
  def index
    @identity_matchings = IdentityMatching.all
  end

  # GET /identity_matching/1
  def show
  end

  # GET /identity_matching/new
  def new
    @identity_matching = IdentityMatching.new
  end

  # GET /identity_matching/1/edit
  def edit
  end

  # POST /identity_matchings
  def create
    @identity_matching = IdentityMatching.new(identity_matching_params)

	# Save inputs
	if @identity_matching.request_json.empty? then # build fhir json from model attributes
		# Save model and run IDILevels validation
		if !@identity_matching.save
			flash.now.alert = "Save failed on client side, please check inputs."
			render :new, status: :unprocessable_entity and return
		end

		# Build IDI Patient Profile and validate
		if !@identity_matching.build_fhir_request
			flash.now.alert = "Save failed on client side, inputs do not conform to IDI Patient Profile."
			render :new, status: :unprocessable_entity and return
		end
	else # validate provided fhir request
		# check JSON
		begin
			JSON.parse(@identity_matching.request_json)
		rescue JSON::ParserError => exception
			flash.now.alert = "Operation failed on client side - invalid JSON: #{exception}"
			render :new, status: :unprocessable_entity and return
		rescue Exception => exception
			flash.now.alert = "Operation failed on client side - exception: #{exception}"
			render :new, status: :unprocessable_entity and return
		end

		# check FHIR
		if !@identity_matching.request_fhir.valid?
			flash.now.alert = "Operation rejected by client - invalid FHIR input: #{@identity_matching.request_fhir.validate}"
			render :new, status: :unprocessable_entity and return
		end
	end

	# Send $match request to server with FHIR payload
	payload = self.request_fhir.to_json
	headers = {'Accept' => 'application/fhir+json', 'Content-Length' => payload.length.to_s, 'Content-Type' => 'application/fhir+json'}
	headers.merge!({'Authorization' => "Bearer #{ENV['BEARER_TOKEN']}"}) if ENV.key? 'BEARER_TOKEN'
	begin
		response = RestClient.post(@patient_server.endpoint, payload, headers);
		self.response_status = response.code
		self.response_json = response.body
		self.save
	rescue RestClient::ExceptionWithResponse => exception
		self.response_status = exception.response.code
		self.response_json = exception.to_json
		self.save
		redirect_to @identity_matching, alert: "FHIR Server rejected payload" and return
	rescue Exception => exception
		self.response_status = nil
		self.response_json = exception.to_json
		self.save
		redirect_to @identity_matching, alert: "FHIR Operation could not reach server #{@patient_server.endpoint}." and return
	end

	# Validate response
	if !@identity_matching.response_fhir.valid?
		redirect_to @identity_matching, alert: "Server returned invalid FHIR response." and return
	end

	# Interpret response
	n = @identity_matching.number_of_matches
	if n > 0
		redirect_to @identity_matching, notice: "#{n} #{pluralize(n, 'match')} found!" and return
	else
		redirect_to @identity_matching, notice: "FHIR Matching preformed, no matches found." and return
	end

	<<COMMENT
    respond_to do |format|
      if @identity_matching.save_and_send(@patient_server.endpoint)
		if @identity_matching.response_json && @identity_matching.response_json.fetch('total', 0) > 0
          format.html { redirect_to identity_matching_url(@identity_matching), notice: "Patient matches found!" }
		else
          format.html { redirect_to identity_matching_url(@identity_matching), notice: "Identity match attempted, no patients found." }
		end
      else
		flash.now.alert = "There was an error, please check below."
        format.html { render :new, status: :unprocessable_entity }
      end
    end
	COMMENT
  end

  # PATCH/PUT /identity_matching/1 or /identity_matching/1.json
  def update

	if !@identity_matching.update(identity_matching_params)
	  render :edit, alert: "Update failed on client side, input does not validate..." and return
	end

	# TODO flesh out
	raise StandardError.new "Not Implemented"

	<<COMMENT
    respond_to do |format|
      if @identity_matching.update(identity_matching_params) && @identity_matching.save_and_send(@patient_server.endpoint)
		if @identity_matching.response_json && @identity_matching.response_json.fetch('total', 0) > 0
          format.html { redirect_to identity_matching_url(@identity_matching), notice: "Identity matching request was successfully updated." }
		else
          format.html { redirect_to identity_matching_url(@identity_matching), notice: "Identity match updated, no patients found." }
		end
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
	COMMENT
  end

  # DELETE /identity_matching/1 or /identity_matching/1.json
  def destroy
    @identity_matching.destroy

    respond_to do |format|
      format.html { redirect_to identity_matchings_url, notice: "Patient identity record deleted." }
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

    # Whitelist of input parameters
    def identity_matching_params
	  PERMITTED_INPUTS = [
		:full_name,
		:gender,
		:date_of_birth,
		:address_line1,
		:address_line2,
		:city,
		:state,
		:zipcode,
		:email,
		:mobile,
		:language,
		:drivers_license,
		:national_payor_identifier,
		:passport_number,
		:state_id_number,
		:request_json,
	  ]

      params.require(:identity_matching).permit( *PERMITTED_INPUTS )
    end

end
