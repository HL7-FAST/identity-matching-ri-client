class PatientServer < ApplicationRecord

  # Loose URI Regex adapted from https://www.rfc-editor.org/rfc/rfc2396#appendix-B
  validates :base, format: { with: /\A(([^:\/?#]+):)?(\/\/([^\/?#]*))?([^?#]*)(\?([^#]*))?(#(.*))?\z/ }

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

  # getter for endpoint, built from base_url
  def endpoint
	return self.endpoint( self.base )
  end
end
