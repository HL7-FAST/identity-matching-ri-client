json.extract! authority, :id, :name, :certificate, :private_key, :created_at, :updated_at
json.url authority_url(authority, format: :json)
json.certificate url_for(authority.certificate)
json.private_key url_for(authority.private_key)
