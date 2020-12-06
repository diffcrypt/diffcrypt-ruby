# frozen_string_literal: true

require_relative './encrypted_configuration'

module Diffcrypt
  module Rails
    module ApplicationHelper
      def encrypted(path, key_path: 'config/master.key', env_key: 'RAILS_MASTER_KEY')
        config_path, key_path = resolve_encrypted_paths(path, key_path)

        Diffcrypt::Rails::EncryptedConfiguration.new(
          config_path: config_path,
          key_path: key_path,
          env_key: env_key,
          raise_if_missing_key: config.require_master_key,
        )
      end

      protected

      def resolve_encrypted_paths(config_path, key_path)
        config_path_abs = ::Rails.root.join(config_path)
        key_path_abs = ::Rails.root.join(key_path)

        # We always want to use `config/credentials/[environment]` for consistency
        # If the master credentials do not exist, and a user has not specificed an environment, default to development
        if config_path == 'config/credentials.yml.enc' && ::File.exist?(config_path_abs.to_s) == false
          config_path_abs = ::Rails.root.join('config/credentials/development.yml.enc')
          key_path_abs = ::Rails.root.join('config/credentials/development.key')
        end

        [
          config_path_abs,
          key_path_abs,
        ]
      end
    end
  end
end
