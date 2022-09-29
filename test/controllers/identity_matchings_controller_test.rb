require "test_helper"

class IdentityMatchingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @identity_matching = identity_matchings(:one)
  end

  test "should get index" do
    get identity_matchings_url
    assert_response :success
  end

  test "should get new" do
    get new_identity_matching_url
    assert_response :success
  end

  test "should create identity_matching" do
    assert_difference("IdentityMatching.count") do
      post identity_matchings_url, params: { identity_matching: { address_line1: @identity_matching.address_line1, address_line2: @identity_matching.address_line2, city: @identity_matching.city, date_of_birth: @identity_matching.date_of_birth, email: @identity_matching.email, full_name: @identity_matching.full_name, mobile: @identity_matching.mobile, response_json: @identity_matching.response_json, response_status: @identity_matching.response_status, state: @identity_matching.state, zipcode: @identity_matching.zipcode } }
    end

    assert_redirected_to identity_matching_url(IdentityMatching.last)
  end

  test "should show identity_matching" do
    get identity_matching_url(@identity_matching)
    assert_response :success
  end

  test "should get edit" do
    get edit_identity_matching_url(@identity_matching)
    assert_response :success
  end

#  test "should update identity_matching" do
#    flunk # TODO: controller update
#
#    patch identity_matching_url(@identity_matching), params: { identity_matching: { address_line1: @identity_matching.address_line1, address_line2: @identity_matching.address_line2, city: @identity_matching.city, date_of_birth: @identity_matching.date_of_birth, email: @identity_matching.email, full_name: @identity_matching.full_name, mobile: @identity_matching.mobile, response_json: @identity_matching.response_json, response_status: @identity_matching.response_status, state: @identity_matching.state, zipcode: @identity_matching.zipcode } }
#    assert_redirected_to identity_matching_url(@identity_matching)
#  end

  test "should destroy identity_matching" do
    assert_difference("IdentityMatching.count", -1) do
      delete identity_matching_url(@identity_matching)
    end

    assert_redirected_to new_identity_matching_url
  end
end
