class UDAPController < ApplicationController

  # GET /udap/register
  # Runs UDAP dynamic client registration on patient server
  def register
	redirect_to root_url, alert: "UDAP dynamic client registration is still under development..."
  end

end
