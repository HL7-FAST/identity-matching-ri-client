class IdentityMatchingRequest < ApplicationRecord

  # TODO: add validations

  serialize :response_body, JSON

  # return pretty string for address
  def address
	return "#{address_line1}, #{address_line2}\n#{city}, #{state}, #{zipcode}"
  end

  # build IDI Patient FHIR::Model
  # returns:
  # 	FHIR::Model instance of IDIPatient profile
  def request_fhir
	idi_patient_hash = {}
	# TODO: build fhir resource
	return FHIR.from_contents( idi_patient_hash.to_json )
  end

  # connect to a url and save response
  # params:
  # 	base_url: string (in proper URL format)
  # returns:
  # 	response_status: integer
  # throws:
  #     RestClient::ExceptionWithResponse
  def execute!(base_url)
	payload = request_fhir
	response = RestClient.post(File.join(base_url, "Patient/$match"), request_fhir, {accept: :json, content_length: payload.length});
  end

  # parse response body into FHIR::Model
  # returns:
  # 	FHIR::Model instance OR
  #     nil (no response body)
  def response_fhir
	return nil unless response_body
	FHIR.from_contents(response_body)
  end

end
