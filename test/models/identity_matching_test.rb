require "test_helper"

class IdentityMatchingTest < ActiveSupport::TestCase
  setup do
	@im1 = identity_matchings(:one)
	@im2 = identity_matchings(:two)
  end

  test "IdentityMatching model exists" do
    assert IdentityMatching
  end

  test "IdentityMatching fixtures validated" do
	assert @im1
	assert @im2
  end

end
