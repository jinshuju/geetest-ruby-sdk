require 'logger'
require 'geetest_ruby_sdk/version'
require 'geetest_ruby_sdk/account'

# This module is used internally by GeetestRubySdk to set up account
# and write logs
# Mandatory parameters to set up an instance:
# * :geetest_id
# * :geetest_key
module GeetestRubySdk
  BASE_URL = 'http://api.geetest.com'
  JSON_FORMAT = '1'

  class << self
    attr_writer :logger

    def logger
      @logger ||= Logger.new($stdout).tap do |log|
        log.progname = name
      end
    end

    def setup(geetest_id, geetest_key)
      GeetestRubySdk::Account.new geetest_id, geetest_key
    end
  end
end
