# frozen_string_literal: true

require 'test_helper'

require 'diffcrypt/rails/encrypted_configuration'

class Diffcrypt::Rails::EncryptedConfigurationTest < Minitest::Test
  def configuration
    Diffcrypt::Rails::EncryptedConfiguration.new(
      config_path: "#{__dir__}/../../fixtures/example.yml.enc",
      key_path: "#{__dir__}/../../fixtures/master.key",
      env_key: 'RAILS_MASTER_KEY',
      raise_if_missing_key: false,
    )
  end

  # This verifies that encrypted and unecrypted data can't be accidently the
  # same, which would create false positive tests and a major security issue
  def test_that_fixtures_are_different
    refute_equal ::File.read("#{__dir__}/../../fixtures/example.yml.enc"), ::File.read("#{__dir__}/../../fixtures/example.yml")
  end

  def test_that_fixture_can_be_decrypted
    assert_equal configuration.read, ::File.read("#{__dir__}/../../fixtures/example.yml")
  end
end
