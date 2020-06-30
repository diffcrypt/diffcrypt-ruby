# rubocop:disable Layout/LineLength
# frozen_string_literal: true

require 'pathname'
require 'tmpdir'
require 'securerandom'
require 'yaml'

require 'active_support/message_encryptor'

require_relative './version'

module Diffcrypt
  class Encryptor
    DEFAULT_CIPHER = 'aes-128-gcm'

    def self.generate_key(cipher = DEFAULT_CIPHER)
      SecureRandom.hex(ActiveSupport::MessageEncryptor.key_len(cipher))
    end

    def initialize(key, cipher: DEFAULT_CIPHER)
      @key = key
      @cipher = cipher
      @encryptor ||= ActiveSupport::MessageEncryptor.new([key].pack('H*'), cipher: cipher)
    end

    # @param [String] contents The raw YAML string to be encrypted
    def decrypt(contents)
      yaml = YAML.safe_load contents
      decrypted = decrypt_hash yaml['data']
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
    # @param [String, nil] original_encrypted_contents The original (encrypted) content to determine which keys have changed
    # @return [String]
    def encrypt(contents, original_encrypted_contents = nil)
      data = encrypt_data contents, original_encrypted_contents
      YAML.dump(
        'client' => "diffcrypt-#{Diffcrypt::VERSION}",
        'cipher' => @cipher,
        'checksum' => Digest::MD5.hexdigest(Marshal.dump(data)),
        'data' => data,
      )
    end

    # @param [String] contents The raw YAML string to be encrypted
    # @param [String, nil] original_encrypted_contents The original (encrypted) content to determine which keys have changed
    # @return [Hash] Encrypted hash containing the data
    def encrypt_data(contents, original_encrypted_contents = nil)
      yaml = YAML.safe_load contents
      original_yaml = original_encrypted_contents ? YAML.safe_load(original_encrypted_contents)['data'] : nil
      encrypt_values yaml, original_yaml
    end

    # @param [String] value Plain text string that needs encrypting
    # @return [String]
    def encrypt_string(value)
      @encryptor.encrypt_and_sign value
    end

    # TODO: Fix the complexity of this method
    # rubocop:disable Metrics/PerceivedComplexity, Metrics/MethodLength, Metrics/CyclomaticComplexity
    # @param [Hash] keys
    # @return [Hash]
    def encrypt_values(data, original_data = nil)
      data.each do |key, value|
        original_encrypted_value = original_data ? original_data[key] : nil
        data[key] = if value.is_a?(Hash) || value.is_a?(Array)
                      encrypt_values(value, original_encrypted_value)
                    else
                      original_decrypted_value = original_encrypted_value ? decrypt_string(original_encrypted_value) : nil
                      key_changed = original_decrypted_value.nil? || original_decrypted_value != value
                      key_changed ? encrypt_string(value) : original_encrypted_value
                    end
      end
      data
    end
    # rubocop:enable Metrics/PerceivedComplexity, Metrics/MethodLength, Metrics/CyclomaticComplexity

    # @param [String] value The encrypted value that needs decrypting
    # @return [String]
    def decrypt_string(value)
      @encryptor.decrypt_and_verify value
    end
  end
end

# rubocop:enable Layout/LineLength
