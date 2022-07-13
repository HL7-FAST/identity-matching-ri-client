require "application_system_test_case"

class IdentityMatchingRequestsTest < ApplicationSystemTestCase
  setup do
    @identity_matching_request = identity_matching_requests(:one)
  end

  test "visiting the index" do
    visit identity_matching_requests_url
    assert_selector "h1", text: "Identity matching requests"
  end

  test "should create identity matching request" do
    visit identity_matching_requests_url
    click_on "New identity matching request"

    fill_in "Address line1", with: @identity_matching_request.address_line1
    fill_in "Address line2", with: @identity_matching_request.address_line2
    fill_in "City", with: @identity_matching_request.city
    fill_in "Date of birth", with: @identity_matching_request.date_of_birth
    fill_in "Email", with: @identity_matching_request.email
    fill_in "Full name", with: @identity_matching_request.full_name
    fill_in "Mobile", with: @identity_matching_request.mobile
    fill_in "Response json", with: @identity_matching_request.response_json
    fill_in "Response status", with: @identity_matching_request.response_status
    fill_in "State", with: @identity_matching_request.state
    fill_in "Zipcode", with: @identity_matching_request.zipcode
    click_on "Create Identity matching request"

    assert_text "Identity matching request was successfully created"
    click_on "Back"
  end

  test "should update Identity matching request" do
    visit identity_matching_request_url(@identity_matching_request)
    click_on "Edit this identity matching request", match: :first

    fill_in "Address line1", with: @identity_matching_request.address_line1
    fill_in "Address line2", with: @identity_matching_request.address_line2
    fill_in "City", with: @identity_matching_request.city
    fill_in "Date of birth", with: @identity_matching_request.date_of_birth
    fill_in "Email", with: @identity_matching_request.email
    fill_in "Full name", with: @identity_matching_request.full_name
    fill_in "Mobile", with: @identity_matching_request.mobile
    fill_in "Response json", with: @identity_matching_request.response_json
    fill_in "Response status", with: @identity_matching_request.response_status
    fill_in "State", with: @identity_matching_request.state
    fill_in "Zipcode", with: @identity_matching_request.zipcode
    click_on "Update Identity matching request"

    assert_text "Identity matching request was successfully updated"
    click_on "Back"
  end

  test "should destroy Identity matching request" do
    visit identity_matching_request_url(@identity_matching_request)
    click_on "Destroy this identity matching request", match: :first

    assert_text "Identity matching request was successfully destroyed"
  end
end
