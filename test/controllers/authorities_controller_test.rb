require "test_helper"

class AuthoritiesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @authority = authorities(:one)
  end

  test "should get index" do
    get authorities_url
    assert_response :success
  end

  test "should get new" do
    get new_authority_url
    assert_response :success
  end

  test "should create authority" do
    assert_difference("Authority.count") do
      post authorities_url, params: { authority: { name: @authority.name } }
    end

    assert_redirected_to authority_url(Authority.last)
  end

  test "should show authority" do
    get authority_url(@authority)
    assert_response :success
  end

  test "should get edit" do
    get edit_authority_url(@authority)
    assert_response :success
  end

  test "should update authority" do
    patch authority_url(@authority), params: { authority: { name: @authority.name } }
    assert_redirected_to authority_url(@authority)
  end

  test "should destroy authority" do
    assert_difference("Authority.count", -1) do
      delete authority_url(@authority)
    end

    assert_redirected_to authorities_url
  end
end
