# frozen_string_literal: true

module Geetest
  module V3
    # This class is used internally by Geetest to send the request
    # Mandatory parameters to initialize an instance:
    # * :captcha_id
    # * :captcha_key
    #
    # => register: to register a geetest service
    # Optional parameters
    # * :digest_mod => encrypt mode
    # * :options => some options for callback like user_name, password
    #
    # => validate?: to validate if the geetest is success
    # Required parameters
    # * :challenge => the code from client generated by geetest
    # * :validate => the code from client generated by geetest
    # * :seccode => the code from client generated by geetest
    # Optional parameters
    # * :digest_mod => encrypt mode
    # * :options => some options for callback like user_name, password
    class Account
      BASE_URL = 'http://api.geetest.com'
      JSON_FORMAT = '1'
      DEFAULT_DIGEST_MOD = 'md5'

      attr_accessor :captcha_id, :captcha_key, :digest_mod

      def initialize(captcha_id, captcha_key, **options)
        @captcha_id = captcha_id
        @captcha_key = captcha_key
        @digest_mod = options.fetch(:digest_mod, Account::DEFAULT_DIGEST_MOD)
      end

      def register(options = {})
        Register.new(account: self).register(**options)
      end

      def validate?(data = {})
        options = data.transform_keys(&:to_sym)
        challenge = options.delete(:challenge)
        validate = options.delete(:validate)
        seccode = options.delete(:seccode)

        Validator.new(account: self).valid?(challenge, validate, seccode, **options)
      end
    end
  end
end
