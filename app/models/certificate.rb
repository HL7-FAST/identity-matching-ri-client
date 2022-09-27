#require_relative '../serializers/pem_serializer.rb'

class Certificate < ApplicationRecord

  serialize :x509, PEM

  belongs_to :authority, optional: true

  # self join
  has_many :dependents, class_name: "Certificate", foreign_key: "issuer_id"
  belongs_to :issuer, class_name: "Certificate", optional: true

  # class method - create trust chain through Certificate self-join
  #     i.e: (End Entity Cert) certificate <- certificate.issuer <- certificate.issuer.issuer (ROOT CA)
  # params: [end-cert ... (ordered intermediate certs) ... root CA],
  #     where each element is an OpenSSL::X509::Certificate object
  # returns: trust chain as [ Certificate, ... ]
  def self.create_chain(*args)
    return [ Certificate.create(x509: args[0]) ] if args.length == 1
    cert_array = args.reverse
    last_cert = Certificate.create(x509: cert_array[0])
    (1...cert_array.length).each do |i|
        cert = Certificate.create(x509: cert_array[i], issuer: last_cert)
        last_cert = cert
    end
    return last_cert.chain
  end

  # returns issuer/trust chain of [ Certificate, ... ], where last element is Root CA
  def chain
    ret = [ self ]
    while ret.last.issuer do
        ret << ret.last.issuer
    end
    ret
  end
end
