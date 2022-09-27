
class PEM

    class Error < StandardError
    end

    # object -> database string
    def self.dump(value)
        return nil if value == nil
        raise PEM::Error.new("#{value} PEM encoding not found") if !value.respond_to? :to_pem
        return value.to_pem
    end

    # database string -> object
    def self.load(str)
        if str == nil
            return nil
        elsif str.include? 'RSA PRIVATE KEY'
            return OpenSSL::PKey::RSA.new(str)
        elsif str.include? 'RSA PUBLIC KEY'
            return OpenSSL::PKey::RSA.new(str)
        elsif str.include? 'CERTIFICATE'
            return OpenSSL::X509::Certificate.new(str)
        else
            raise PEM::Error.new("database record not supported PEM: #{str}")
        end
    end

end
