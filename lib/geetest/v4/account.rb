# frozen_string_literal: true

require 'uri'

module Geetest
  module V4
    class Account
      DEFAULT_API_SERVER = 'http://gcaptcha4.geetest.com'
      DIGEST_MOD = 'hmac_sha256'

      attr_accessor :captcha_id, :captcha_key, :api_server

      def initialize(captcha_id, captcha_key, **options)
        @captcha_id = captcha_id
        @captcha_key = captcha_key
        @api_server = URI.parse options.fetch(:api_server, DEFAULT_API_SERVER)
      end

      def validate?(lot_number:, captcha_output:, pass_token:, gen_time:, **options)
        payload = {
          lot_number: lot_number,
          captcha_output: captcha_output,
          pass_token: pass_token,
          gen_time: gen_time,
          sign_token: Encryptor.encrypt(lot_number).with(captcha_key).by(DIGEST_MOD).to_s
        }
        response = request! payload, options
        Geetest.logger.debug "Geetest validate failed, reason: #{response['reason']}" if response['result'] != 'success'
        response['result'] == 'success'
      rescue *Geetest.exceptions_to_degraded_mode => e
        Geetest.logger.info "Geetest validate request failed for #{e.message}, fall back to degraded mode"
        true
      end

      private

      def request!(payload, options = {})
        response = RestClient.post "#{api_server}/validate?captcha_id=#{captcha_id}", options.merge(payload)
        JSON.parse response.body
      end
    end
  end
end
