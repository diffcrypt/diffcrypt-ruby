require_relative './encryptor'

module Diffcrypt
  class File
    attr_reader :file

    def initialize(path)
      @path = ::File.absolute_path path
    end

    def encrypted?
      to_yaml['cipher']
    end

    def cipher
      to_yaml['cipher'] || Encryptor::DEFAULT_CIPHER
    end

    # @return [Boolean]
    def exists?
      ::File.exist?(@path)
    end

    # @return [String] Raw contents of the file
    def read
      @read ||= ::File.read(@path)
    end

    def encrypt(key)
      return read if encrypted?

      Encryptor.new(key).encrypt(read)
    end

    def decrypt(key)
      return read unless encrypted?

      Encryptor.new(key).decrypt(read)
    end

    def to_yaml
      @to_yaml ||= YAML.safe_load(read)
    end
  end
end
