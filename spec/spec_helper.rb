require 'bundler/setup'
require 'webmock/rspec'
require 'timecop'
require 'geetest_ruby_sdk'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before(:each) do
    GeetestRubySdk.logger = Logger.new(STDOUT)
  end
end
