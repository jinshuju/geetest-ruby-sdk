# frozen_string_literal: true

require 'logger'
require 'rest-client'

require 'geetest/concerns/degraded_mode'
require 'geetest/account'
require 'geetest/encryptor'
require 'geetest/register'
require 'geetest/validator'

# This module is used internally by GeetestRubySdk to set up account
# and write logs
# Mandatory parameters to set up an instance:
# * :geetest_id
# * :geetest_key
module Geetest
  BASE_URL = 'http://api.geetest.com'
  JSON_FORMAT = '1'
  DEFAULT_DIGEST_MOD = 'md5'

  class << self
    attr_writer :logger

    def setup(channel_or_config)
      if channel_or_config.is_a? Hash
        config = channel_or_config.transform_keys(&:to_sym)
        channel_name = config.delete(:channel) || :default
        geetest_id = config.delete(:id)
        geetest_key = config.delete(:key)
        channels[channel_name.to_sym] = Geetest::Account.new(geetest_id, geetest_key, **config)
      else
        Object.new.tap do |unready_channel|
          unready_channel.define_singleton_method(:with) { |opts| Geetest.setup opts.merge(channel: channel_or_config) }
        end
      end
    end

    def channel(channel_name = :default)
      channels[channel_name.to_sym]
    end

    def logger
      @logger = ::Rails.logger if @logger.nil? && defined?(::Rails)
      @logger ||= Logger.new(STDERR)
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
  end
end
