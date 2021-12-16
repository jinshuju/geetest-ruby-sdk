# frozen_string_literal: true

module Geetest
  # This class is used internally by Geetest to validate by request or local
  # => valid?: to send a post request to geetest service and return if a geetest is valid
  # parameters
  # * :challenge
  # * :validate
  # * :seccode
  # * :options => some options for callback like user_name, password
  class Validator
    include DegradedMode

    VALIDATE_URL = '/validate.php'

    attr_reader :account, :digest_mod, :response

    def initialize(account:, digest_mod: nil)
      @account = account
      @digest_mod = digest_mod || account.digest_mod
    end

    def valid?(challenge, validate, seccode, **options)
      return false if validate.to_s.empty? || challenge.to_s.empty?

      degraded?(challenge) ? degraded_valid?(challenge, validate) : remote_valid?(challenge, validate, seccode, options)
    end

    private

    def degraded_valid?(challenge, validate)
      Encryptor.encrypt(challenge).by(digest_mod).eq? validate
    end

    def remote_valid?(challenge, validate, seccode, options)
      return false if seccode.to_s.empty?
      return false unless validate == Encryptor.encrypt(challenge).with(account.geetest_key).by(digest_mod).to_validate

      remote_seccode_valid?(challenge, validate, seccode, **options)
    end

    def remote_seccode_valid?(challenge, validate, seccode, **options)
      payload = { challenge: challenge, validate: validate, seccode: seccode }
      options = { json_format: Geetest::JSON_FORMAT }.merge options.transform_keys(&:to_sym)
      @response = request! payload, options

      Encryptor.encrypt(seccode).with(account.geetest_key).by(digest_mod).eq? @response['seccode']
    end

    def request!(payload, options = {})
      response = RestClient.post "#{Geetest::BASE_URL}#{VALIDATE_URL}", payload.merge(options)
      JSON.parse response.body
    end
  end
end
