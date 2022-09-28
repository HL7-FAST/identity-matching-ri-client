require "test_helper"

class PatientServerTest < ActiveSupport::TestCase

  setup do
	@patient_server = patient_servers(:one)
  end

  test "patient server exists" do
	assert PatientServer
	assert @patient_server
  end

  ## removing for now - this should be reclassified as a system or integration test
  # test "patient server is running" do
  # puts "WARNING: Atleast one PatientServer path must exist in database"
  # puts "WARNING: An Identity Matching Server must be running at port 4000 for this test to pass"
  # assert_nothing_raised do
  #     response = RestClient.options(PatientServer.last&.base)
  #   end
  # end

  test "PatientServer#join builds url" do
	assert @patient_server.join('/path', '/to', '/foo') == "localhost:4000/path/to/foo"
	assert @patient_server.join('path', 'to', 'foo') == "localhost:4000/path/to/foo"
	assert @patient_server.join('path/', '/to/', '/foo') == "localhost:4000/path/to/foo"
	assert @patient_server.join('path/', 'to/', 'foo/') == "localhost:4000/path/to/foo"
  end

  test "PatientServer#endpoint builds identity matching url" do
	assert @patient_server.endpoint == 'localhost:4000/Patient/$match'
  end

end
