class IdentityMatching < ApplicationRecord
  # This model handles a IDIPatient profile, converting to/from FHIR JSON,
  # sending request, and receiving response. Relies on active record validations
  # to make this client's IDIPatient profile conform to IG, although technically
  # only the server needs do validation.
  #
  # See: http://build.fhir.org/ig/HL7/fhir-identity-matching-ig/artifacts.html

  # IDI Patient Level
  enum :level, [ :idi_patient_base, :idi_patient_l0, :idi_patient_l1 ]

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
	if self.level == :idi_patient_l0
		fhir_json = IDI_L0_PARAMETER.result_with_hash({model: self})
	elsif self.level == :idi_patient_l1
		fhir_json = IDI_L1_PARAMETER.result_with_hash({model: self})
	else
		fhir_json = IDI_BASE_PARAMETER.result_with_hash({model: self})
	end
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
		# NOTE: Assumes US Passport number, although IG allows any nation's passport number,
        #       in which case condition would be self.has?(:passport_number) && self.has?(:country)
		total += 10;
	end
	if self.has?(:drivers_license) || self.has?(:state_id_number)
		total += 10;
	end
	if self.has?(:address_line1) && (self.has?(:zipcode) || (self.has?(:city) && self.has?(:state))) ||
	   self.has?(:email) ||
	   self.has?(:phone_number) ||
	   self.has?(:national_insurance_payor_identifier) ||
	   self.photo.attached? then
		total += 4;
	end
	if self.full_name&.split.length > 1
		total += 4;
	end
	if self.date_of_birth
		total += 2;
	end
	total
  end


  # returns number of matches found by server response
  # will return 0 even if request was never made
  # returns: int
  def number_of_matches
	self.response_fhir.send(:total) || 0
  end

end
