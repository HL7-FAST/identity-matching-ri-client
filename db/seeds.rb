# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

#Certificate.create_self_signed_x509_cert() # TODO remove


# Create self-signed root certificate authority
skey = OpenSSL::PKey::RSA.new 2048
sha = OpenSSL::Digest.new 'SHA256'
cert = OpenSSL::X509::Certificate.new
cert.version = 2 # specify v3 certificate
cert.serial = 1
cert.subject = OpenSSL::X509::Name.parse "/CN=Identity Matching RI Client/O=MITRE"
cert.issuer = cert.subject # the self-signing
cert.public_key = skey.public_key
cert.not_before = Time.now
cert.not_after = cert.not_before + 1.year # expires in 1 year
ef = OpenSSL::X509::ExtensionFactory.new
ef.subject_certificate = cert
ef.issuer_certificate = cert
cert.add_extension(ef.create_extension("basicConstraints","CA:TRUE",true))
cert.add_extension(ef.create_extension("keyUsage","keyCertSign, cRLSign", true))
cert.add_extension(ef.create_extension("subjectKeyIdentifier","hash",false))
cert.add_extension(ef.create_extension("authorityKeyIdentifier","keyid:always",false))
cert.add_extension(ef.create_extension("subjectAltName", "DNS:https://fhir-secid-client.herokuapp.com")) # TODO refactor into config
cert.sign(skey, sha)

Authority.find_or_create_by(name: "Self-Signed Certificate Authority") do |a|
    a.private_key = skey;
    a.certificate = cert;
end
