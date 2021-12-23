# frozen_string_literal: true

require 'logger'
require 'rest-client'

require 'geetest/v3/concerns/degraded_mode'
require 'geetest/v3/account'
require 'geetest/encryptor'
require 'geetest/v3/register'
require 'geetest/v3/validator'

require 'geetest/v4/account'

module Geetest
  class << self
    attr_writer :logger

    # Set up a geetest account and keep it in +Geetest.channels+
    # @param [String, Symbol, Hash] channel_or_config
    #
    # @option opts [String] id Geetest CaptchaId
    # @option opts [String] key Geetest CaptchaKey
    # @option opts [String, Symbol] channel (:default) Which channel to store the instance
    # @option opts [String, Symbol] :version (:V3) Which Captcha version to use
    #
    # other available opts depend on which Captcha version used
    #   eg. digest_mod, api_server
    #
    # Set up by a hash config:
    #   Geetest.setup(id: 'geetest_id', key: 'geetest_key')
    #   Geetest.channel
    #
    # Set up by a hash config with channel name:
    #   Geetest.setup(id: 'geetest_id', key: 'geetest_key', channel: 'login')
    #   Geetest.channel(:login)
    #
    # Set up a channel by another way:
    #   Geetest.setup('login').with(id: 'geetest_id', key: 'geetest_key')
    #   Geetest.channel(:login)
    #
    def setup(channel_or_config)
      if channel_or_config.is_a? Hash
        build_channel(channel_or_config)
      else
        Object.new.tap do |unready_channel|
          unready_channel.define_singleton_method(:with) { |opts| Geetest.setup opts.merge(channel: channel_or_config) }
        end
      end
    end

    def build_channel(config)
      config = config.transform_keys(&:to_sym)
      channel_name = config.delete(:channel) || :default
      captcha_version = config.delete(:version) || :V3
      captcha_id = config.delete(:id)
      captcha_key = config.delete(:key)
      account_klass = Geetest.const_get("#{captcha_version.upcase}::Account", false)
      channels[channel_name.to_sym] = account_klass.new(captcha_id, captcha_key, **config)
    end

    def channel(channel_name = :default)
      channels[channel_name.to_sym]
    end

    def channels
      @channels ||= {}
    end

    def exceptions_to_degraded_mode
      @exceptions_to_degraded_mode ||= [
        RestClient::InternalServerError,
        RestClient::NotFound,
        JSON::ParserError
      ]
    end

    def logger
      @logger ||= Logger.new(STDERR)
    end
  end
end
