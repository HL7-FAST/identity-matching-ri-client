require "test_helper"

class Oauth2ControllerTest < ActionDispatch::IntegrationTest
  test "should get start" do
    get oauth2_start_url
    assert_response :success
  end

  # TODO: restart test

  test "should reject redirect without proper params" do
    get oauth2_redirect_url
    assert_response :bad_request
  end
end
