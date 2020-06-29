# frozen_string_literal: true

require_relative './encryptor'
require_relative './version'

module Diffcrypt
  class CLI < Thor
    desc 'decrypt <path>', 'Decrypt a file'
    method_option :key, aliases: %i[k], required: true
    def decrypt(path)
      contents = File.read(path)
      puts encryptor.decrypt(contents)
    end

    desc 'encrypt <path>', 'Encrypt a file'
    method_option :key, aliases: %i[k], required: true
    def encrypt(path)
      contents = File.read(path)
      puts encryptor.encrypt(contents)
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
    end
  end
end
