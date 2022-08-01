require "test_helper"

class Oauth2ControllerTest < ActionDispatch::IntegrationTest
  test "should get start" do
    get oauth2_start_url
    assert_response :success
  end

  test "should get redirect" do
    get oauth2_redirect_url
    assert_response :success
  end
end
