# frozen_string_literal: true

require 'pathname'
require 'tmpdir'

require 'active_support/ordered_options'
require 'active_support/core_ext/hash'
require 'active_support/core_ext/module/delegation'
require 'active_support/core_ext/object/inclusion'

module Diffcrypt
  module Rails
    class EncryptedConfiguration
      attr_reader :content_path
      attr_reader :key_path
      attr_reader :env_key
      attr_reader :raise_if_missing_key

      delegate :[], :fetch, to: :config
      delegate_missing_to :options

      def initialize(config_path:, key_path:, env_key:, raise_if_missing_key:)
        @content_path = Pathname.new(File.absolute_path(config_path)).yield_self do |path|
          path.symlink? ? path.realpath : path
        end
        @key_path = Pathname.new(key_path)
        @env_key = env_key
        @raise_if_missing_key = raise_if_missing_key
        @active_support_encryptor = ActiveSupport::MessageEncryptor.new([key].pack('H*'), cipher: Encryptor::CIPHER)
      end

      # Allow a config to be started without a file present
      # @return [String] Returns decryped content or a blank string
      def read
        raise MissingContentError, content_path unless !key.nil? && content_path.exist?

        decrypt content_path.binread
      rescue MissingContentError
        ''
      end

      def write(contents)
        deserialize(contents)

        IO.binwrite "#{content_path}.tmp", encrypt(contents)
        FileUtils.mv "#{content_path}.tmp", content_path
      end

      def config
        @config ||= deserialize(read).deep_symbolize_keys
      end

      # @raise [MissingKeyError] Will raise if key is not set
      # @return [String]
      def key
        read_env_key || read_key_file || handle_missing_key
      end

      def change(&block)
        writing read, &block
      end

      protected

      def writing(contents)
        tmp_file = "#{Process.pid}.#{content_path.basename.to_s.chomp('.enc')}"
        tmp_path = Pathname.new File.join(Dir.tmpdir, tmp_file)
        tmp_path.binwrite contents

        yield tmp_path

        updated_contents = tmp_path.binread

        write(updated_contents) if updated_contents != contents
      ensure
        FileUtils.rm(tmp_path) if tmp_path&.exist?
      end

      # @param [String] contents
      # @return [String]
      def encrypt(contents)
        encryptor.encrypt contents
      end

      # @param [String] contents
      # @return [String]
      def decrypt(contents)
        if contents.index('---').nil?
          @active_support_encryptor.decrypt_and_verify contents
        else
          encryptor.decrypt contents
        end
      end

      # @return [Encryptor]
      def encryptor
        @encryptor ||= Encryptor.new key
      end

      def read_env_key
        ENV[env_key]
      end

      def read_key_file
        key_path.binread.strip if key_path.exist?
      end

      # @raise [MissingKeyError]
      # @return [void]
      def handle_missing_key
        raise MissingKeyError.new(key_path: key_path, env_key: env_key) if raise_if_missing_key
      end

      def options
        @options ||= ActiveSupport::InheritableOptions.new(config)
      end

      def deserialize(config)
        YAML.safe_load(config).presence || {}
      end
    end
  end
end
