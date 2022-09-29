class PatientServer < ApplicationRecord

  # Loose URI Regex adapted from https://www.rfc-editor.org/rfc/rfc2396#appendix-B
  validates :base, format: { with: /\A(([^:\/?#]+):)?(\/\/([^\/?#]*))?([^?#]*)(\?([^#]*))?(#(.*))?\z/ }
  validates :base, presence: true

  validates :client_id, length: { maximum: 255 }
  validates :identity_provider, length: { maximum: 255 }


  # construct url from base url
  # params:
  # 	args: strings or responds_to to_s
  # returns:
  # 	<base_url>/to/my/resource: string
  def join(*args)
	args.insert(0, self.base)
	args.map! { |x| x.class == String ? x : x.to_s }
	args.map! { |x| x.starts_with?('/') ? x.slice(1,x.length) : x }
	args.map! { |x| x.ends_with?('/') ? x.chomp('/') : x }
	return args.join('/')
  end

  # getter for identity-matching endpoint
  def endpoint
	return self.join('Patient', '$match');
  end

  def to_s
    base
  end
end
