# frozen_string_literal: true

require 'diffcrypt/encryptor'
require 'diffcrypt/version'

module Diffcrypt
  class Error < StandardError; end

  class MissingContentError < RuntimeError
    def initialize(content_path)
      super "Missing encrypted content file in #{content_path}."
    end
  end

  class MissingKeyError < RuntimeError
    def initialize(key_path:, env_key:)
      super \
        'Missing encryption key to decrypt file with. ' \
          "Ask your team for your master key and write it to #{key_path} or put it in the ENV['#{env_key}']."
    end
  end
end
