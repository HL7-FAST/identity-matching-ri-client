class IdentityMatchingRequest < ApplicationRecord

  # TODO: add validations

  serialize :response_json, JSON

  # Load fhir payload as JSON ERB template
  MATCH_PARAMETER_ERB = ERB.new(File.read(Rails.root.join('resources', 'match_parameter.json.erb')))

  # return pretty string for address
  def address
	return "#{address_line1} #{address_line2}\n#{city} #{state} #{zipcode}"
  end

  # build IDI Patient FHIR::Model
  # returns:
  # 	FHIR::Model instance of IDIPatient profile
  def request_fhir
	erb_params = {} # TODO
	idi_patient_json = IdentityMatchingRequest::MATCH_PARAMETER_ERB.result_with_hash(erb_params)

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

	conn = Faraday.new(url: url, headers: {'Content-Type' => 'application/fhir+json'}) do |faraday|
	  faraday.response :logger, nil, { bodies: true, log_level: :debug }
  	  faraday.response :raise_error
	end

	payload = request_fhir.to_json
    print "POST ", url
	puts "=== payload ===\n#{payload}==========\n"

	begin
	  response = conn.post do |req| req.body = payload end
	  puts "=== response ===\n#{response}\n==========\n"

	  self.response_status = response.env.status
	  self.response_json = FHIR.from_contents(response.body).to_hash # str -> fhir -> hash
	  return self.save!

	rescue Faraday::Error => exception
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
