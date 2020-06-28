# frozen_string_literal: true

require 'pathname'
require 'tmpdir'
require 'securerandom'
require 'yaml'

require 'active_support/message_encryptor'

module Diffcrypt
  class Encryptor
    CIPHER = 'aes-128-gcm'

    def self.generate_key
      SecureRandom.hex(ActiveSupport::MessageEncryptor.key_len(CIPHER))
    end

    def initialize(key)
      @key = key
      @encryptor ||= ActiveSupport::MessageEncryptor.new([key].pack('H*'), cipher: CIPHER)
    end

    # @param [String] contents The raw YAML string to be encrypted
    def decrypt(contents)
      yaml = YAML.safe_load contents
      decrypted = decrypt_hash yaml
      YAML.dump decrypted
    end

    # @param [Hash] data
    # @return [Hash]
    def decrypt_hash(data)
      data.each do |key, value|
        data[key] = if value.is_a?(Hash) || value.is_a?(Array)
                      decrypt_hash(value)
                    else
                      decrypt_string value
                    end
      end
      data
    end

    # @param [String] contents The raw YAML string to be encrypted
    def encrypt(contents)
      yaml = YAML.safe_load contents
      encrypted = encrypt_values yaml
      YAML.dump encrypted
    end

    # @param [String] value Plain text string that needs encrypting
    # @return [String]
    def encrypt_string(value)
      @encryptor.encrypt_and_sign value
    end

    # @param [Hash] keys
    # @return [Hash]
    def encrypt_values(data)
      data.each do |key, value|
        data[key] = if value.is_a?(Hash) || value.is_a?(Array)
                      encrypt_values(value)
                    else
                      encrypt_string value
                    end
      end
      data
    end

    # @param [String] value The encrypted value that needs decrypting
    # @return [String]
    def decrypt_string(value)
      @encryptor.decrypt_and_verify value
    end
  end
end
