# frozen_string_literal: true

require 'test_helper'

require 'diffcrypt/rails/application_helper'

class MockApplication
  include Diffcrypt::Rails::ApplicationHelper

  Config = Struct.new(:require_master_key)

  def config
    Config.new(true)
  end
end

module Rails
  def self.root
    Pathname.new('/app')
  end
end

class Diffcrypt::Rails::EncryptedConfigurationTest < Minitest::Test
  def setup
    @app = ::MockApplication.new
    @mock = 'mocked encrypted configuration'
  end

  def test_that_encrypted_method_loads_encrypted_configuration_with_development_when_master_does_not_exist
    init = lambda do |options|
      expected_options = {
        config_path: Pathname.new('/app/config/credentials/development.yml.enc'),
        key_path: Pathname.new('/app/config/credentials/development.key'),
        env_key: 'RAILS_MASTER_KEY',
        raise_if_missing_key: true,
      }
      assert_equal expected_options, options

      @mock
    end

    ::Diffcrypt::Rails::EncryptedConfiguration.stub :new, init do
      assert_equal @mock, @app.encrypted('config/credentials.yml.enc', key_path: 'config/master.key')
    end
  end

  def test_that_encrypted_method_loads_encrypted_configuration_with_master_when_master_exists
    init = lambda do |options|
      expected_options = {
        config_path: Pathname.new('/app/config/credentials.yml.enc'),
        key_path: Pathname.new('/app/config/master.key'),
        env_key: 'RAILS_MASTER_KEY',
        raise_if_missing_key: true,
      }
      assert_equal expected_options, options

      @mock
    end

    ::File.stub :exist?, ->(path) { path == '/app/config/credentials.yml.enc' } do
      ::Diffcrypt::Rails::EncryptedConfiguration.stub :new, init do
        assert_equal @mock, @app.encrypted('config/credentials.yml.enc', key_path: 'config/master.key')
      end
    end
  end

  def test_that_encrypted_method_loads_encrypted_configuration_with_development
    init = lambda do |options|
      expected_options = {
        config_path: Pathname.new('/app/config/credentials/development.yml.enc'),
        key_path: Pathname.new('/app/config/credentials/development.key'),
        env_key: 'RAILS_MASTER_KEY',
        raise_if_missing_key: true,
      }
      assert_equal expected_options, options

      'mocked encrypted configuration'
    end

    ::Diffcrypt::Rails::EncryptedConfiguration.stub :new, init do
      assert_equal @mock, @app.encrypted('config/credentials/development.yml.enc', key_path: 'config/credentials/development.key')
    end
  end
end
