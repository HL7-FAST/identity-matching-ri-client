class Certificate < ApplicationRecord

  def self.create_self_signed_x509_cert()
    private_key = OpenSSL::PKey::RSA.new(2048)
    public_key = private_key.public_key
    subject = "/C=US/CN=Test"

    cert = OpenSSL::X509::Certificate.new
    cert.subject = cert.issuer = OpenSSL::X509::Name.parse(subject)
    cert.not_before = Time.now
    cert.not_after = Time.now + 365 * 24 * 60 * 60
    cert.public_key = public_key
    cert.serial = 0 # In production, this should be a secure random unique positive integer
    cert.version = 2

    ef = OpenSSL::X509::ExtensionFactory.new
    ef.subject_certificate = cert
    ef.issuer_certificate = cert

    # TODO: double check extensions
    cert.extensions = [
      ef.create_extension("basicConstraints","CA:TRUE", true),
      ef.create_extension("subjectKeyIdentifier", "hash"),
      # ef.create_extension("keyUsage", "cRLSign,keyCertSign", true),
    ]
    cert.add_extension ef.create_extension("authorityKeyIdentifier",
                                           "keyid:always,issuer:always")

    cert.sign private_key, OpenSSL::Digest::SHA256.new

    return self.create({pem: cert.to_pem})
  end

  # convert to `OpenSSL::X509::Certificate` object
  def to_x509
    OpenSSL::X509::Certificate.new( self.pem )
  end

end
