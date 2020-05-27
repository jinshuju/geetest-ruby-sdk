require 'openssl'

module GeetestRubySdk
  # This class is used internally by GeetestRubySdk to encrypt message
  # => encrypt_with: to encrypt a message with a digest_mod and a secret key
  # parameters
  # * :code => the message to be encrypted
  # * :digest_mod => encrypt mode
  # * :secret_key => secret_key used by hmac_sha256 encryption
  # => md5_encrypt, sha256_encrypt, sha256_encrypt: to encrypt with md5, sha256 and hmac_sha256
  # parameters
  # * :code => the message to be encrypted
  # * :secret_key => secret_key used by hmac_sha256 encryption
  class Encrypt
    DIGEST_MOD_LIST = %w(md5 sha256 hmac_sha256)
    DEFAULT_DIGEST_MOD = 'md5'

    class << self
      def encrypt_with(code, digest_mod = DEFAULT_DIGEST_MOD, secret_key = nil)
        return md5_encrypt(code, secret_key) unless DIGEST_MOD_LIST.include? digest_mod

        send("#{digest_mod}_encrypt", code, secret_key)
      end

      def md5_encrypt(code, _)
        OpenSSL::Digest::MD5.hexdigest code
      end

      def sha256_encrypt(code, _)
        OpenSSL::Digest::SHA256.hexdigest code
      end

      def hmac_sha256_encrypt(code, secret_key)
        OpenSSL::HMAC.hexdigest('SHA256', secret_key, code)
      end
    end
  end
end
