class PatientServer < ApplicationRecord

  # Loose URI Regex adapted from https://www.rfc-editor.org/rfc/rfc2396#appendix-B
  validates :base, format: { with: /\A(([^:\/?#]+):)?(\/\/([^\/?#]*))?([^?#]*)(\?([^#]*))?(#(.*))?\z/ }

end
