# frozen_string_literal: true

require 'logger'
require 'rest-client'
require 'rails'

require 'geetest_ruby_sdk/concerns/degraded_mode'
require 'geetest_ruby_sdk/account'
require 'geetest_ruby_sdk/encryptor'
require 'geetest_ruby_sdk/register'
require 'geetest_ruby_sdk/validator'
require 'geetest_ruby_sdk/version'

# This module is used internally by GeetestRubySdk to set up account
# and write logs
# Mandatory parameters to set up an instance:
# * :geetest_id
# * :geetest_key
module GeetestRubySdk
  BASE_URL = 'http://api.geetest.com'
  JSON_FORMAT = '1'
  DEFAULT_DIGEST_MOD = 'md5'

  class << self
    attr_writer :logger

    def logger
      @logger || ::Rails.logger
    end

    def setup(geetest_id, geetest_key)
      GeetestRubySdk::Account.new geetest_id, geetest_key
    end
  end

  module Rails
    class Engine < ::Rails::Engine; end
  end
end
