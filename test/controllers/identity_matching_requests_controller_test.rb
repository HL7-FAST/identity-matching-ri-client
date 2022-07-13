require "test_helper"

class IdentityMatchingRequestsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @identity_matching_request = identity_matching_requests(:one)
  end

  test "should get index" do
    get identity_matching_requests_url
    assert_response :success
  end

  test "should get new" do
    get new_identity_matching_request_url
    assert_response :success
  end

  test "should create identity_matching_request" do
    assert_difference("IdentityMatchingRequest.count") do
      post identity_matching_requests_url, params: { identity_matching_request: { address_line1: @identity_matching_request.address_line1, address_line2: @identity_matching_request.address_line2, city: @identity_matching_request.city, date_of_birth: @identity_matching_request.date_of_birth, email: @identity_matching_request.email, full_name: @identity_matching_request.full_name, mobile: @identity_matching_request.mobile, response_json: @identity_matching_request.response_json, response_status: @identity_matching_request.response_status, state: @identity_matching_request.state, zipcode: @identity_matching_request.zipcode } }
    end

    assert_redirected_to identity_matching_request_url(IdentityMatchingRequest.last)
  end

  test "should show identity_matching_request" do
    get identity_matching_request_url(@identity_matching_request)
    assert_response :success
  end

  test "should get edit" do
    get edit_identity_matching_request_url(@identity_matching_request)
    assert_response :success
  end

  test "should update identity_matching_request" do
    patch identity_matching_request_url(@identity_matching_request), params: { identity_matching_request: { address_line1: @identity_matching_request.address_line1, address_line2: @identity_matching_request.address_line2, city: @identity_matching_request.city, date_of_birth: @identity_matching_request.date_of_birth, email: @identity_matching_request.email, full_name: @identity_matching_request.full_name, mobile: @identity_matching_request.mobile, response_json: @identity_matching_request.response_json, response_status: @identity_matching_request.response_status, state: @identity_matching_request.state, zipcode: @identity_matching_request.zipcode } }
    assert_redirected_to identity_matching_request_url(@identity_matching_request)
  end

  test "should destroy identity_matching_request" do
    assert_difference("IdentityMatchingRequest.count", -1) do
      delete identity_matching_request_url(@identity_matching_request)
    end

    assert_redirected_to identity_matching_requests_url
  end
end
