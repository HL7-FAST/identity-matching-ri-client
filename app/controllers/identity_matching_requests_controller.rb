class IdentityMatchingRequestsController < ApplicationController
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
      if @identity_matching_request.save
        format.html { redirect_to identity_matching_request_url(@identity_matching_request), notice: "Identity matching request was successfully created." }
        format.json { render :show, status: :created, location: @identity_matching_request }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @identity_matching_request.errors, status: :unprocessable_entity }
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
end
