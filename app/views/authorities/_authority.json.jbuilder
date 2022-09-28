json.extract! authority, :id, :name, :certificate, :created_at, :updated_at
json.url authority_url(authority, format: :json)
json.certificate authority.certificate.to_pem
