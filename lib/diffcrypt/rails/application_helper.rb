# frozen_string_literal: true

require_relative './encrypted_configuration'

module Diffcrypt
  module Rails
    module ApplicationHelper
      def encrypted(path, key_path: 'config/master.key', env_key: 'RAILS_MASTER_KEY')
        # TODO: Make this configutable via Rails.application.config
        if path == 'config/credentials.yml.enc'
          path = 'config/credentials/development.yml.enc'
          key_path = 'config/credentials/development.key'
        end

        Diffcrypt::Rails::EncryptedConfiguration.new(
          config_path: ::Rails.root.join(path),
          key_path: ::Rails.root.join(key_path),
          env_key: env_key,
          raise_if_missing_key: config.require_master_key,
        )
      end
    end
  end
end
