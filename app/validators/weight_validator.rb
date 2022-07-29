# weight_validator.rb
#
# Validates IdentityMatching weight score is high enough for its specified IDI Level, and returns
# a proper error message if not. See: http://build.fhir.org/ig/HL7/fhir-identity-matching-ig/artifacts.html


class WeightValidator < ActiveModel::Validator
	def validate(record)
		Rails.logger.debug "Validating weight for #{record} -- weight = #{record.weight}"
		if record.idi_patient_l0? && (record.weight < 10)
			Rails.logger.debug "Validating weight for #{record} -- 1"
			record.errors.add(:idi_level, 'Input scores do not have a weighted total of at least 10. Consider classifying the identity as IDI Base or adding an identifier.')	
		elsif record.idi_patient_l1? && (record.weight < 20)
			Rails.logger.debug "Validating weight for #{record} -- 2"
			if record.weight < 10
				Rails.logger.debug "Validating weight for #{record} -- 3"
				record.errors.add(:idi_level, 'Input scores do not have a weighted total of at least 20. Consider classifying the identity as IDI Base or adding two identifiers.')	
			else
				Rails.logger.debug "Validating weight for #{record} -- 4"
				record.errors.add(:idi_level, 'Input scores do not have a weighted total of at least 20. Consider classifying the identity as IDI L0 or adding an identifier.')	
			end
		end
	end
end
