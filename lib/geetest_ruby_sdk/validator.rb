require 'rest-client'

module GeetestRubySdk
  # This class is used internally by GeetestRubySdk to validate by request or local
  # => valid?: to send a post request to geetest service and return if a geetest is valid
  # parameters
  # * :challenge
  # * :validate
  # * :seccode
  # * :options => some options for callback like user_name, password
  # => local_valid?: to validate on local when geetest service is unusable
  # parameters
  # * :challenge
  # * :validate
  class Validator
    VALIDATE_URL = '/validate.php'

    attr_reader :account, :digest_mod

    def initialize(account:, digest_mod: GeetestRubySdk::Encrypt::DEFAULT_DIGEST_MOD)
      @account = account
      @digest_mod = digest_mod
    end

    def local_valid?(challenge, validate)
      validate == encrypt(challenge)
    end

    def valid?(challenge, validate, seccode, **options)
      secret = account.geetest_key + 'geetest' + challenge
      return false unless validate == encrypt(secret)

      payload = {
        challenge: challenge,
        validate: validate,
        seccode: seccode,
        json_format: GeetestRubySdk::JSON_FORMAT
      }.merge options.transform_keys(&:to_sym)
      request!(payload) == encrypt(seccode)
    end

    private

    def encrypt(str)
      GeetestRubySdk::Encrypt.encrypt_with(str, digest_mod: digest_mod, secret_key: account.geetest_key)
    end

    def request!(payload)
      response = RestClient.post "#{GeetestRubySdk::BASE_URL}#{VALIDATE_URL}", payload
      response_json = JSON.parse response.body
      GeetestRubySdk.logger.info(
        "Geetest validate model_probability of #{payload[:challenge]} => #{response_json['model_probability']}"
      )
      response_json['seccode']
    rescue JSON::ParserError => e
      GeetestRubySdk.logger.info "Geetest validate request failed for #{e.message}"
      raise 'validate request failed'
    end
  end
end
