# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'diffcrypt'

# Predictable key used for deterministic encryption values in tests
#
# @example Generate an expected value for tests
#   Diffcrypt::Encryptor.new('99e1f86b9e61f24c56ff4108dd415091').encrypt_string('some value here')
TEST_KEY_128 = ::File.read("#{__dir__}/fixtures/aes-128-gcm.key").strip
TEST_KEY_256 = ::File.read("#{__dir__}/fixtures/aes-256-gcm.key").strip

# Custom test output
require 'minitest/reporters'
Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new

require 'minitest/autorun'
