# frozen_string_literal: true

require_relative './encryptor'
require_relative './file'
require_relative './version'

module Diffcrypt
  class CLI < Thor
    desc 'decrypt <path>', 'Decrypt a file'
    method_option :key, aliases: %i[k], required: true
    def decrypt(path)
      file = File.new(path)
      ensure_file_exists(file)
      say file.decrypt(key)
    end

    desc 'encrypt <path>', 'Encrypt a file'
    method_option :key, aliases: %i[k], required: true
    method_option :cipher, default: Encryptor::DEFAULT_CIPHER
    def encrypt(path)
      file = File.new(path)
      ensure_file_exists(file)
      say file.encrypt(key, cipher: options[:cipher])
    end

    desc 'generate-key', 'Generate a 32 bit key'
    method_option :cipher, default: Encryptor::DEFAULT_CIPHER
    def generate_key
      say Encryptor.generate_key(options[:cipher])
    end

    desc 'version', 'Show client version'
    def version
      say Diffcrypt::VERSION
    end

    no_commands do
      def key
        options[:key]
      end

      def encryptor
        @encryptor ||= Encryptor.new(key)
      end

      # @param [Diffcrypt::File] path
      def ensure_file_exists(file)
        abort('[ERROR] File does not exist') unless file.exists?
      end

      def self.exit_on_failure?
        true
      end
    end
  end
end
