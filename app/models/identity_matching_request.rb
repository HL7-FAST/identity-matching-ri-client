class IdentityMatchingRequest < ApplicationRecord

  # TODO: add validations

  serialize :response_json, JSON

  # Load fhir payload as JSON ERB template
  MATCH_PARAMETER_ERB = ERB.new(File.read( Rails.root.join('resources', 'match_parameter.json.erb') ))

  # return pretty string for address
  def address
	return "#{address_line1} #{address_line2}\n#{city} #{state} #{zipcode}"
  end

  # class method - construct <base_url>/Patient/$match
  # params:
  # 	base_url: string
  # returns:
  #     endpoint url: string
  def self.endpoint(base_url)
	if base_url.ends_with? '/'
	  return base_url + 'Patient/$match'
	else
	  return base_url + '/Patient/$match'
	end
  end

  # build IDI Patient FHIR::Model
  # returns:
  # 	FHIR::Model instance of IDIPatient profile
  def request_fhir
	erb_params = {} # TODO
	idi_patient_json = IdentityMatchingRequest::MATCH_PARAMETER_ERB.result(erb_params)

	#puts "==="
	#puts idi_patient_json
	#puts "==="

	return FHIR.from_contents( idi_patient_json )
  end

  # save request data and attempt to query endpoint for response
  # params:
  # 	base_url: string (in proper URL format)
  # returns:
  # 	true if object saved and response received (regardless of match) OR
  #     false otherwise
  def save_and_send(url)
	return false unless self.save

	payload = request_fhir.to_json
    puts "POST ", url
	puts "=== payload ===\n#{payload}==========\n"
	begin
	  response = RestClient.post(url, payload, {accept: 'application/fhir+json', content_length: payload.length});
	  puts "=== response ===\n#{response}\n==========\n"
	  self.response_status = response.code
	  self.response_json = FHIR.from_contents(response.body).to_hash # str -> fhir -> hash
	  return self.save!
	rescue RestClient::ExceptionWithResponse => exception
	  puts "ExceptionWithResponse"
	  response = exception.response
	  puts "=== response ===\n#{response}\n==========\n"
	  self.response_status = response.code
	  self.response_json = JSON.parse(response.body)
	  return self.save!
	rescue Exception => exception
	  puts "=== Exception ===\n#{exception}\n========\n"
	  return false
	end
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
