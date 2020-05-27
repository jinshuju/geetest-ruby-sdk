require 'rest-client'
require 'geetest_ruby_sdk/encrypt'

module GeetestRubySdk
  # This class is used internally by GeetestRubySdk to send a register request
  # => get: to send a get request to geetest service and return a valid challenge
  # parameters
  # * :geetest_id => geetest id
  # * :geetest_key => use to encrypt messages
  # * :digest_mod => encrypt mode
  # * :options => some options for callback like user_name, password
  class RegisterRequest
    REGISTER_URL = '/register.php'

    class << self
      def get(geetest_id, geetest_key, digest_mod = GeetestRubySdk::Encrypt::DEFAULT_DIGEST_MOD, options = {})
        payload = { gt: geetest_id, json_format: GeetestRubySdk::JSON_FORMAT }.merge options
        response = RestClient.get "#{GeetestRubySdk::BASE_URL}#{REGISTER_URL}", params: payload
        response_json = JSON.parse response.body
        secret = response_json['challenge'] + geetest_key
        return unless response_json['challenge'].length == 32

        GeetestRubySdk::Encrypt.encrypt_with secret, digest_mod: digest_mod, secret_key: geetest_key
      rescue JSON::ParserError => e
        GeetestRubySdk.logger.info "Register request failed for #{e.message}"
        raise 'register failed'
      end
    end
  end
end
