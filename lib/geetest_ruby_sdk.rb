# frozen_string_literal: true

require 'forwardable'
require 'geetest'

module GeetestRubySdk
  extend SingleForwardable

  delegate [:logger, :logger=, :exceptions_to_degraded_mode] => Geetest

  def self.setup(geetest_id, geetest_key)
    Geetest.setup id: geetest_id, key: geetest_key
  end

  if defined?(::Rails)
    class Engine < ::Rails::Engine
      # Rails -> use app/assets directory.
    end
  end
end
