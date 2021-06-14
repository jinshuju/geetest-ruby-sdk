# frozen_string_literal: true

module GeetestRubySdk
  # This class is used internally by GeetestRubySdk to send a register request
  # => register: to send a get request to geetest service and return a valid result
  # parameters
  # * :options => some options for callback like user_name, password
  class Register
    include DegradedMode

    REGISTER_URL = '/register.php'.freeze

    attr_reader :account, :digest_mod, :response

    def initialize(account:, digest_mod: nil)
      @account = account
      @digest_mod = digest_mod || account.digest_mod
    end

    def register(**options)
      payload = { gt: account.geetest_id }
      options = { json_format: GeetestRubySdk::JSON_FORMAT }.merge options.transform_keys(&:to_sym)
      @response = request! payload, options
      on_remote_mode
    rescue *GeetestRubySdk.exceptions_to_degraded_mode => e
      GeetestRubySdk.logger.info "Geetest register request failed for #{e.message}, fall back to degraded mode"
      on_degraded_mode
    end

    private

    def request!(payload, options = {})
      response = RestClient.get "#{GeetestRubySdk::BASE_URL}#{REGISTER_URL}", params: payload.merge(options)
      JSON.parse response.body
    end

    def on_remote_mode
      {
        success: 1,
        gt: account.geetest_id,
        challenge: Encryptor.encrypt(@response['challenge']).with(account.geetest_key).by(digest_mod).to_challenge
      }
    end

    def on_degraded_mode
      {
        success: 0,
        gt: account.geetest_id,
        challenge: degraded_challenge
      }
    end
  end
end
