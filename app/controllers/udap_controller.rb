class UDAPController < ApplicationController

  # POST /udap/register
  # Runs UDAP dynamic client registration on patient server
  def register
	redirect_to root_url, alert: "UDAP Reg WIP!"
  end

end
