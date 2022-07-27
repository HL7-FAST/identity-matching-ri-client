class IdentityMatching < ApplicationRecord
  # This model handles a IDIPatient profile, converting to/from FHIR JSON,
  # sending request, and receiving response. Relies on active record validations
  # to make this client's IDIPatient profile conform to IG, although technically
  # only the server needs do validation.
  #
  # See: http://build.fhir.org/ig/HL7/fhir-identity-matching-ig/artifacts.html

  # IDI Patient Level
  enum :level, [:base, :level_0, :level_1]

  # Photo
  has_one_attached :photo

  # TODO: add validations
  validates :full_name, presence: true
  validates :date_of_birth, presence: true
  # validates :email, format: { with: /@/ }
  # validates :mobile, format: { with: /[^\a]/ }

  # Load fhir profiles as JSON ERB templates
  MATCH_PARAMETER_ERB = ERB.new(File.read(Rails.root.join('resources', 'match_parameter.json.erb')))
  IDI_BASE_PARAMETER = ERB.new(File.read(Rails.root.join('resources', 'idi_base_parameter.json.erb')))
  IDI_L0_PARAMETER = ERB.new(File.read(Rails.root.join('resources', 'idi_level0_parameter.json.erb')))
  IDI_L1_PARAMETER = ERB.new(File.read(Rails.root.join('resources', 'idi_level1_parameter.json.erb')))

  # Identifier code system from IDIPatient Profile
  IDENTIFIER_SYSTEM = "http://terminology.hl7.org/CodeSystem/v2-0203";

  # parse request body as FHIR
  # returns: FHIR::Model instance OR nil
  def request_fhir
	return nil unless self.request_json
	FHIR.from_contents(self.request_json)
  end

  # parses fhir model into request body json
  # param fhir_obj: FHIR::Model instance
  # returns: nil or string (json)
  def request_fhir=(fhir_obj)
	return nil unless fhir_obj.is_a? FHIR::Model
	self.request_json = fhir_obj.to_json
  end

  # parse response body as FHIR
  # returns: FHIR::Model instance OR nil
  def response_fhir
	return nil unless self.response_json
	FHIR.from_contents(self.response_json)
  end

  # parses fhir model into response body json
  # param fhir_obj: FHIR::Model instance
  # returns nil or string (json)
  def response_fhir=(fhir_obj)
	return nil unless fhir_obj.is_a? FHIR::Model
	self.response_json = fhir_obj.to_json	
  end

  # parse full name and return last name
  # returns: string
  def last_name
	return "" unless self.full_name.strip.include? ' '
	self.full_name.strip.titleize.split.last
  end

  # parse full name and return all other names
  # returns: array of strings
  def given_names
	names = self.full_name.strip.titleize.split
	names.pop
	names
  end

  # returns: boolean (true if given_names is not empty array, otherwise false)
  def given_names?
	!!self.given_names&.empty?
  end

  # return pretty string for address
  def address
	return "#{address_line1} #{address_line2}\n#{city} #{state} #{zipcode}"
  end

  # return true if any hard identifier is provided
  def identifiers?
	return self.drivers_license || self.national_insurance_payor_identifier || self.state_id_number || self.passport_number
  end

  # returns array of hashes that is convenient for templating fhir identifiers
  # reference: http://build.fhir.org/ig/HL7/fhir-identity-matching-ig/ValueSet-Identity-Identifier-vs.html
  def identifiers
	ret = []
	ret << {system: IDENTIFIER_SYSTEM, code: 'DL', display: 'Drivers License', value: self.drivers_license} if self.drivers_license
	ret << {system: IDENTIFIER_SYSTEM, code: 'NIIP', display: 'National Insurance Payor Identifier', value: self.national_insurance_payor_identifier} if self.national_insurance_payor_identifier
	ret << {system: IDENTIFIER_SYSTEM, code: 'STID', display: 'State Level Identifier', value: self.state_id_number} if self.drivers_license
	ret << {system: IDENTIFIER_SYSTEM, code: 'PPN', display: 'Drivers License', value: self.passport_number} if self.passport_number
	ret
  end

  # Constructs fhir json artifact from model attributes
  # Utilizes files in resources/
  # Uses fhir_models gem to validate
  # Will overwrite old request fhir construct
  # returns: true if fhir model is valid and saves successfully ELSE
  #          false
  def build_request_fhir
	fhir_json = IDI_BASE_PARAMETER.result_with_hash({model: self})
	self.request_fhir = FHIR.from_contents(fhir_json)
	self.request_fhir.valid? && self.save
  end

  # TODO: use l0 or l1 profiles

  # param sym: symbol (for attribute)
  # returns: true if model has attribute string and string is not empty
  def has?(sym)
	!!( self.send(sym) && self.send(sym).respond_to?(:'empty?') && !self.send(sym).empty? )
  end

  # Compute "input quality and security" weight from model attributes according to IG
  # returns: int (weight)
  def weight
	total = 0;
	if self.has? :passport_number
		# NOTE: This application assumes US Passport number, although could be any passport number by IG
		total += 10;
	end
	if self.has?(:drivers_license) || self.has?(:state_id_number)
		total += 10;
	end
	if self.has?(:address_line1) && (self.has?(:zipcode) || (self.has?(:city) && self.has?(:state))) ||
	   self.has?(:email) ||
	   self.has?(:phone_number) ||
	   self.photo.attached?
		total += 4;
	end
  end

  def execute_request(endpoint_url)
	raise StandardError.new "TODO execute_request"
  end

  def number_of_matches
	raise StandardError.new "TODO number_of_matches"
  end

  # =================
  #	 OLD STUFF BELOW
  # =================

  # build IDI Patient FHIR::Model
  # returns:
  # 	FHIR::Model instance of IDIPatient profile
  def to_fhir
	erb_params = {
		last_name: nil,
		given_names: nil,
		gender: nil,
		date_of_birth: nil,
		line1: nil,
		line2: nil,
		city: nil,
		state: nil,
		zipcode: nil,
		email: nil,
		mobile: nil,
		drivers_license: nil,
		niip: nil,
		state_id_number: nil,
		passport_number: nil
	}

	# parse name
	if self.full_name
	  names = self.full_name.strip.titleize.split();
	  erb_params[:last_name] = names[-1];
	  if names.length > 1
		names.pop
	    erb_params[:given_names] = names;
	  end
	end

	# gender
	if self.gender
		erb_params[:gender] = self.gender.strip.downcase
		# should be male, female, other, or unknown
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
	erb_params[:niip] = self.national_insurance_payor_identifier.strip if self.national_insurance_payor_identifier
	erb_params[:state_id_number] = self.state_id_number.strip if self.state_id_number
	erb_params[:passport_number] = self.passport_number.strip if self.passport_number

	idi_patient_json = IdentityMatching::MATCH_PARAMETER_ERB.result_with_hash(erb_params)

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
	  faraday.request :authorization, 'Bearer', Proc.new { ENV.fetch('BEARER_TOKEN', 'No Token') } # evaluate at runtime per request
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


end
