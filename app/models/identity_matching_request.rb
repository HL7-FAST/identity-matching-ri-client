class IdentityMatchingRequest < ApplicationRecord

  # TODO: add validations

  serialize :response_json, JSON


  MATCH_PARAMETER = <<~EOS
	{
	  "resourceType": "Parameters",
	  "id": "%{id}",
	  "parameter": [
	    {
	      "name": "resource",
	      "resource": {
	        "resourceType": "Patient",
	        "identifier": [
	          {
	            "use": "usual",
	            "type": {
	              "coding": [
	                {
	                  "system": "http://hl7.org/fhir/v2/0203",
	                  "code": "MR"
	                }
	              ]
	            },
	            "system": "urn:oid:1.2.36.146.595.217.0.1",
	            "value": "12345"
	          }
	        ],
	        "name": [
	          {
				"text": "%{name}"
	          }
	        ],
	        "gender": "male",
	        "birthDate": "1974-12-25"
	      }
	    },
	    {
	      "name": "count",
	      "valueInteger": "3"
	    },
	    {
	      "name": "onlyCertainMatches",
	      "valueBoolean": "false"
	    }
	  ]
	}
  EOS


  # return pretty string for address
  def address
	return "#{address_line1} #{address_line2}\n#{city} #{state} #{zipcode}"
  end

  # build IDI Patient FHIR::Model
  # returns:
  # 	FHIR::Model instance of IDIPatient profile
  def request_fhir
	idi_patient_json = IdentityMatchingRequest::MATCH_PARAMETER % {id: self.id, name: self.full_name}

	puts "==="
	puts idi_patient_json
	puts "==="

	return FHIR.from_contents( idi_patient_json )
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
	return nil unless response_json
	FHIR.from_contents(response_json)
  end

end
