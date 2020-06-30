# frozen_string_literal: true

require 'test_helper'
require 'thor'

require_relative '../../lib/diffcrypt/file'

class Diffcrypt::FileTest < Minitest::Test
  def setup
    @path = "#{__dir__}/../../tmp/test-content-plain.yml"
    @content = 'key: value'
    ::File.write(@path, @content)

    @encrypted_path = "#{__dir__}/../../tmp/test-content-encrypted.yml"
    @encrypted_content = "client: diffcrypt-test\ncipher: #{Diffcrypt::Encryptor::DEFAULT_CIPHER}\ndata:\n  key: value"
    ::File.write(@encrypted_path, @encrypted_content)
  end

  def test_it_reads_content
    file = Diffcrypt::File.new(@path)
    assert_equal file.read, @content
  end

  def test_it_idntifies_as_unencrypted
    file = Diffcrypt::File.new(@path)
    refute file.encrypted?
  end

  def test_it_idntifies_as_encrypted
    file = Diffcrypt::File.new(@encrypted_path)
    assert file.encrypted?
  end
end
