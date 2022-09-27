class AuthoritiesController < ApplicationController
  before_action :set_authority, only: %i[ show edit update destroy ]

  # GET /authorities or /authorities.json
  def index
    @authorities = Authority.all
  end

  # GET /authorities/1 or /authorities/1.json
  def show
    render plain: @authority.certificate.to_pem
  end

  # GET /authorities/new
  def new
    @authority = Authority.new
  end

  # GET /authorities/1/edit
  def edit
  end

  # POST /authorities or /authorities.json
  def create
    @authority = Authority.new(authority_params.slice(:name))
    begin
        pkcs12 = OpenSSL::PKCS12.new( authority_params[:pkcs12].read, authority_params[:password] )
        @authority.private_key = pkcs12.private_key
        @authority.certificate = pkcs12.certificate
        # TODO: certificate sanity checks
        # TODO: handle certificate chain
        # pkcs12.ca_certs => Array of OpenSSL::X509::Certificate(s)
    rescue Exception => e
        redirect_to(new_authority_url, {alert: "Error decoding PKCS#12 file: #{e}"}) and return
    end

    respond_to do |format|
      if @authority.save
        format.html { redirect_to(udap_start_url, {notice: "Authority #{@authority.name} added successfully."}) }
        format.json { render :show, status: :created, location: @authority }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @authority.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /authorities/1 or /authorities/1.json
  def update
    respond_to do |format|
      if @authority.update(authority_params)
        format.html { redirect_to authority_url(@authority), notice: "Authority was successfully updated." }
        format.json { render :show, status: :ok, location: @authority }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @authority.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /authorities/1 or /authorities/1.json
  def destroy
    @authority.destroy

    respond_to do |format|
      format.html { redirect_to authorities_url, notice: "Authority was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_authority
      @authority = Authority.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def authority_params
      params.require(:authority).permit(:name, :pkcs12, :password)
    end
end
