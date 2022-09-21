require "test_helper"

class WelcomeControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get welcome_index_url
    assert_response :success
  end

  test "should get terms" do
    get welcome_terms_url
    assert_response :success
  end

  test "should get privacy" do
    get welcome_privacy_url
    assert_response :success
  end

  test "should get cookies" do
    get welcome_privacy_url + '#cookies'
    assert_response :success
  end

end
