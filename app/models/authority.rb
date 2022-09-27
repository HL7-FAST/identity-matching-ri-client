require_relative '../serializers/pem_serializer.rb'

class Authority < ApplicationRecord

  has_one :certificate # End-entity Certificate object
  serialize :private_key, PEM # OpenSSL::PKey::RSA object

  encrypts :private_key # Rails 7 built-in AES-GCM 128 bit non-deterministic encryption

  validates :name, presence: true, length: {maximum: 255}


  # First try to get public key from OpenSSL::PKey::RSA object
  # Then fallback to OpenSSL::X509::Certificate object
  def public_key
    pkey = self.private_key
    if pkey.public?
        return pkey.public_key
    end

    cert = self.certificate
    return cert.public_key
  end

  # returns trust chain array of OpenSSL::X509::Certificate objects
  def x509_chain
    self.certificate.chain.map(&:x509)
  end

end
