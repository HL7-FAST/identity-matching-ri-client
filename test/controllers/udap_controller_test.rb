require "test_helper"

class UDAPControllerTest < ActionDispatch::IntegrationTest
  test "should get register" do
    get udap_register_url
    assert_response :success
  end
end
