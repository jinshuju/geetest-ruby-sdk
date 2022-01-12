require 'openssl'

module Geetest
  # This class is used internally by Geetest to encrypt message
  # It prefers to be used with chain methods
  #
  #  Encryptor.encrypt(string).with(secret).by(digest_mod).to_s
  #
  # chain methods
  # * :encrypt(string) => the message to be encrypted
  # * :by(digest_mod) => encrypt mode
  # * :with(secret) => secret_key used by #to_challenge/#to_validate and hmac_sha256 encryption
  #
  # return methods
  # * :to_challenge => generate a geetest challenge string
  # * :to_validate => generate a geetest validate string
  # * :to_s => just digest the given string by given digest_mod
  #
  # assert methods
  # * :eq?(string)
  #
  class Encryptor

    def self.encrypt(str)
      new.encrypt(str)
    end

    def encrypt(str)
      @str = str.to_s
      self
    end

    def with(secret)
      @secret = secret.to_s
      self
    end

    def by(digest_mod)
      @digest_mod = digest_mod.to_s
      self
    end

    def to_challenge
      return if @str.to_s.empty? || @secret.to_s.empty?

      hexdigest(@str + @secret)
    end

    def to_validate
      return if @str.to_s.empty? || @secret.to_s.empty?

      hexdigest(@secret + 'geetest' + @str)
    end

    def to_s
      return if @str.to_s.empty?

      hexdigest(@str)
    end
    alias inspect to_s

    def eq?(string)
      self.to_s == string
    end

    private

    def hexdigest(payload)
      case @digest_mod
      when 'sha256'
        OpenSSL::Digest::SHA256.hexdigest payload
      when 'hmac_sha256'
        OpenSSL::HMAC.hexdigest('SHA256', @secret, payload)
      else
        OpenSSL::Digest::MD5.hexdigest payload
      end
    end
  end
end
