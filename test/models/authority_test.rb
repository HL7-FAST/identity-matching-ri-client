require "test_helper"

class AuthorityTest < ActiveSupport::TestCase
  setup do
    skey = OpenSSL::PKey::RSA.new 1024
    sha = OpenSSL::Digest.new 'SHA1' # don't use SHA1 in production
    cert = OpenSSL::X509::Certificate.new

    # self-sign certificate
    cert.version = 2 # cf. RFC 5280 - to make it a "v3" certificate
    cert.serial = 1 # don't use serial 1 in production
    cert.subject = OpenSSL::X509::Name.parse "/CN=Test Certificate/O=MITRE"
    cert.issuer = cert.subject # the self-signing
    cert.public_key = skey.public_key
    cert.not_before = Time.now
    cert.not_after = cert.not_before + 1.year
    ef = OpenSSL::X509::ExtensionFactory.new
    ef.subject_certificate = cert
    ef.issuer_certificate = cert
    cert.add_extension(ef.create_extension("basicConstraints","CA:TRUE",true))
    cert.add_extension(ef.create_extension("keyUsage","keyCertSign, cRLSign", true))
    cert.add_extension(ef.create_extension("subjectKeyIdentifier","hash",false))
    cert.add_extension(ef.create_extension("authorityKeyIdentifier","keyid:always",false))
    cert.sign(skey, sha)

    @authority = Authority.new(name: "Test Authority", private_key: skey);
    @authority.build_certificate(x509: cert);
    @authority.save!
  end

  test "authority model exists" do
    assert Authority
  end

  test "authority record created" do
    assert @authority
  end

  test "authority has certificate" do
    assert @authority.certificate
    assert @authority.certificate.x509.class == OpenSSL::X509::Certificate
  end

  test "authority has private key" do
    assert @authority.private_key
    assert @authority.private_key.class == OpenSSL::PKey::RSA
  end

  test "authority has public key" do
    assert @authority.public_key
  end

  test "authority can build chain" do
    assert @authority.x509_chain
  end

end
