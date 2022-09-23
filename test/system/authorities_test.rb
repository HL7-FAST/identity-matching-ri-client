require "application_system_test_case"

class AuthoritiesTest < ApplicationSystemTestCase
  setup do
    @authority = authorities(:one)
  end

  test "visiting the index" do
    visit authorities_url
    assert_selector "h1", text: "Authorities"
  end

  test "should create authority" do
    visit authorities_url
    click_on "New authority"

    fill_in "Name", with: @authority.name
    click_on "Create Authority"

    assert_text "Authority was successfully created"
    click_on "Back"
  end

  test "should update Authority" do
    visit authority_url(@authority)
    click_on "Edit this authority", match: :first

    fill_in "Name", with: @authority.name
    click_on "Update Authority"

    assert_text "Authority was successfully updated"
    click_on "Back"
  end

  test "should destroy Authority" do
    visit authority_url(@authority)
    click_on "Destroy this authority", match: :first

    assert_text "Authority was successfully destroyed"
  end
end
