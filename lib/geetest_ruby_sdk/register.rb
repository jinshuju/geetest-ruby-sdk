require 'rest-client'
require 'geetest_ruby_sdk/encrypt'

module GeetestRubySdk
  # This class is used internally by GeetestRubySdk to send a register request
  # => register: to send a get request to geetest service and return a valid result
  # parameters
  # * :options => some options for callback like user_name, password
  class Register
    REGISTER_URL = '/register.php'.freeze
    Result = Struct.new(:challenge, :gt, :success, :new_captcha, keyword_init: true)

    attr_reader :account, :digest_mod, :result

    def initialize(account:, digest_mod: GeetestRubySdk::Encrypt::DEFAULT_DIGEST_MOD)
      @account = account
      @digest_mod = digest_mod
      @result = Result.new(gt: account.geetest_id, success: 0)
    end

    def register(**options)
      payload = {
        gt: account.geetest_id,
        json_format: GeetestRubySdk::JSON_FORMAT
      }.merge options.transform_keys(&:to_sym)
      request! payload
      result.to_h.compact
    end

    private

    def request!(payload)
      response = RestClient.get "#{GeetestRubySdk::BASE_URL}#{REGISTER_URL}", params: payload
      response_json = JSON.parse response.body
      secret = response_json['challenge'] + account.geetest_key
      @result.challenge = encrypt(secret)
      @result.success = 1
    rescue RestClient::InternalServerError, JSON::ParserError => e
      GeetestRubySdk.logger.info "Geetest register request failed for #{e.message}, fail back to outage mode"
      failback_process
    end

    def failback_process
      @result.challenge = [*'a'..'z', *'0'..'9'].sample(32).join
      @result.success = 0
    end

    def encrypt(str)
      GeetestRubySdk::Encrypt.encrypt_with(str, digest_mod: digest_mod, secret_key: account.geetest_key)
    end
  end
end
