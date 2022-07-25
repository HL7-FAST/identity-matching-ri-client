json.extract! identity_matching, :id, :full_name, :date_of_birth, :address_line1, :address_line2, :city, :state, :zipcode, :email, :mobile, :response_status, :response_json, :created_at, :updated_at
json.url identity_matching_url(identity_matching, format: :json)
