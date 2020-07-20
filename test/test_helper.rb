# frozen_string_literal: true

require 'simplecov'
require 'simplecov-lcov'
SimpleCov::Formatter::LcovFormatter.config.report_with_single_file = true
SimpleCov::Formatter::LcovFormatter.config do |c|
  c.single_report_path = 'coverage/diffcrypt.lcov'
end
SimpleCov.formatters = SimpleCov::Formatter::MultiFormatter.new(
  [
    SimpleCov::Formatter::HTMLFormatter,
    SimpleCov::Formatter::LcovFormatter,
  ],
)
SimpleCov.start

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'diffcrypt'

# Predictable key used for deterministic encryption values in tests
#
# @example Generate an expected value for tests
#   Diffcrypt::Encryptor.new('99e1f86b9e61f24c56ff4108dd415091').encrypt_string('some value here')
TEST_KEY = File.read("#{__dir__}/fixtures/master.key").strip

require 'minitest/autorun'
