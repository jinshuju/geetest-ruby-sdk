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

      def validate?(data = {})
        payload, options = prepare_payload(data)
        return false if payload.nil?

        response = request! payload, options
        Geetest.logger.debug "Geetest validate failed, reason: #{response['reason']}" if response['result'] != 'success'
        response['result'] == 'success'
      rescue *Geetest.exceptions_to_degraded_mode => e
        Geetest.logger.info "Geetest validate request failed for #{e.message}, fall back to degraded mode"
        true
      end

      private

      def prepare_payload(data)
        options = data.transform_keys(&:to_sym)
        payload = {
          lot_number: options.delete(:lot_number),
          captcha_output: options.delete(:captcha_output),
          pass_token: options.delete(:pass_token),
          gen_time: options.delete(:gen_time)
        }.compact
        return [nil, nil] unless payload.size == 4

        payload[:sign_token] = Encryptor.encrypt(payload[:lot_number]).with(captcha_key).by(DIGEST_MOD).to_s
        [payload, options]
      end

      def request!(payload, options = {})
        response = RestClient.post "#{api_server}/validate?captcha_id=#{captcha_id}", options.merge(payload)
        JSON.parse response.body
      end
    end
  end
end
