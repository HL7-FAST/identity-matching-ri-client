require "test_helper"

class PatientServerTest < ActiveSupport::TestCase

  setup do
	puts "WARNING: An Identity Matching Server (returned by PatientServer#last) must be running for tests to work."
  end

  test "patient server exists" do
	assert PatientServer.last
  end

  test "patient server is running" do
	assert_nothing_raised do
      response = Faraday.options(PatientServer.last&.base)
    end
  end

end
