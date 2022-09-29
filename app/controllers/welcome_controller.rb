class WelcomeController < ApplicationController
  def index
  end

  def terms
  end

  def privacy
  end

  def ifconfig
    # get IP address of server via ifconfig.me for UDAPTestTools
    resp = RestClient.get("https://ifconfig.me/ip");
    render plain: resp.body
  end
end
