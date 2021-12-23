# frozen_string_literal: true

module Geetest
  module V3
    # This class is used internally by Geetest to send a register request
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
        payload = { gt: account.captcha_id }
        options = { json_format: Account::JSON_FORMAT }.merge options.transform_keys(&:to_sym)
        @response = request! payload, options
        on_remote_mode
      rescue *Geetest.exceptions_to_degraded_mode => e
        Geetest.logger.info "Geetest register request failed for #{e.message}, fall back to degraded mode"
        on_degraded_mode
      end

      private

      def request!(payload, options = {})
        response = RestClient.get "#{Account::BASE_URL}#{REGISTER_URL}", params: payload.merge(options)
        JSON.parse response.body
      end

      def on_remote_mode
        {
          success: 1,
          gt: account.captcha_id,
          challenge: Encryptor.encrypt(@response['challenge']).with(account.captcha_key).by(digest_mod).to_challenge
        }
      end

      def on_degraded_mode
        {
          success: 0,
          gt: account.captcha_id,
          challenge: degraded_challenge
        }
      end
    end
  end
end
