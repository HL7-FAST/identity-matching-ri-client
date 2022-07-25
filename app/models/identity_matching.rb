class IdentityMatching < ApplicationRecord

  # TODO: add validations
  validates :full_name, presence: true
  validates :date_of_birth, presence: true

  # validates :email, format: { with: /@/ }
  # validates :mobile, format: { with: /[^\a]/ }

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
  def to_fhir
	erb_params = {last_name: nil, given_names: nil, date_of_birth: nil, line1: nil, line2: nil, city: nil, state: nil, zipcode: nil, email: nil, mobile: nil, drivers_license: nil, gender: nil, nipi: nil}

	#print "===\n", erb_params, "\n====\n"

	# parse name
	if self.full_name
	  names = self.full_name.strip.titleize.split();
	  erb_params[:last_name] = names[-1];
	  if names.length > 1
	    #names.slice!(0, names.length - 1)
	    #erb_params[:given_names] = names;
		names.pop
	    erb_params[:given_names] = names;
	  end
	end

	# gender
	if self.gender
		erb_params[:gender] = self.gender.strip.downcase
	end

	# parse date
	if self.date_of_birth
		erb_params[:date_of_birth] = self.date_of_birth.strftime('%Y-%m-%d');
	end

	# address
	erb_params[:line1] = self.address_line1;
	erb_params[:line2] = self.address_line2;
	erb_params[:city] = self.city;
	erb_params[:state] = self.state;
	erb_params[:zipcode] = self.zipcode;

	# email & phone number
	erb_params[:email] = self.email.strip.downcase if self.email
	erb_params[:mobile] = self.mobile.strip if self.mobile

	# identifiers
	erb_params[:drivers_license] = self.drivers_license.strip if self.drivers_license
	erb_params[:nipi] = self.national_insurance_payer_identifier.strip if self.national_insurance_payer_identifier

	idi_patient_json = IdentityMatching::MATCH_PARAMETER_ERB.result_with_hash(erb_params)

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

	payload = self.to_fhir.to_json
    #print "POST ", url
	#puts "=== payload ===\n#{payload}==========\n"

	begin
	  response = conn.post do |req| req.body = payload end
	  #puts "=== Faraday Response ===\n#{response}\n==========\n" if response

	  self.response_status = response.status
	  fhir_data = FHIR.from_contents(response.body).to_hash
	  
	  # autofill address
	  if fhir_data['entry'] && fhir_data['entry'][0]['address'] && fhir_data['entry'][0]['address'][0]
		self.address_line1 = fhir_data.dig('entry', 0, 'address', 0, 'line', 0);
		self.address_line2 = fhir_data.dig('entry', 0, 'address', 0, 'line', 1);
		self.city = fhir_data.dig('entry', 0, 'address', 0, 'city');
		self.state = fhir_data.dig('entry', 0, 'address', 0, 'state');
		self.zipcode = fhir_data.dig('entry', 0, 'address', 0, 'postalCode');
	  end

	  self.response_json = fhir_data
	  return self.save

	rescue Faraday::ClientError => exception
	  #puts "=== Faraday Client Error ===\n#{exception.response}\n==========\n"
	  self.response_status = exception.response[:status]
	  self.response_json = JSON.parse(exception.response[:body])
	  self.errors.add(:response_status, exception.to_s);
	  return self.save

	rescue Exception => exception
	  #puts "=== Exception ===\n#{exception}\n========\n"
	  self.errors.add(:response_status, exception.to_s);
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
