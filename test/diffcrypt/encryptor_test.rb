# frozen_string_literal: true

require 'test_helper'

ENCRYPTED_VALUE_PATTERN = '([a-z0-9A-Z=/+]+)\-\-([a-z0-9A-Z=/+]+)\-\-([a-z0-9A-Z=/+]+)'

class Diffcrypt::EncryptorTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Diffcrypt::VERSION
  end

  def test_it_decrypts_root_values
    encrypted_content = <<~CONTENT
      secret_key_base: 88Ry6HESUoXBr6QUFXmni9zzfCIYt9qGNFvIWFcN--4xoecI5mqbNRBibI--62qPJbkzzh5h8lhFEFOSaQ==
    CONTENT
    expected = <<~CONTENT
      ---
      secret_key_base: secret_key_base_test
    CONTENT

    assert_equal Diffcrypt::Encryptor.new(TEST_KEY).decrypt(encrypted_content), expected
  end

  def test_it_encrypts_root_values
    encrypted_content = <<~CONTENT
      ---
      secret_key_base: secret_key_base_test
    CONTENT
    expected_pattern = /---\nsecret_key_base: #{ENCRYPTED_VALUE_PATTERN}\n/

    assert_match expected_pattern, Diffcrypt::Encryptor.new(TEST_KEY).encrypt(encrypted_content)
  end

  def test_it_decrypts_nested_structures
    encrypted_content = <<~CONTENT
      secret_key_base: 88Ry6HESUoXBr6QUFXmni9zzfCIYt9qGNFvIWFcN--4xoecI5mqbNRBibI--62qPJbkzzh5h8lhFEFOSaQ==
      aws:
        access_key_id: Ot/uCTEL+8kp61EPctnxNlg=--Be6sg7OdvjZlfxgR--7qRbbf0lA4VgjnUGUrrFwg==
    CONTENT
    expected = <<~CONTENT
      ---
      secret_key_base: secret_key_base_test
      aws:
        access_key_id: AKIAXXX
    CONTENT

    assert_equal Diffcrypt::Encryptor.new(TEST_KEY).decrypt(encrypted_content), expected
  end

  def test_it_encrypts_nested_structures
    encrypted_content = <<~CONTENT
      ---
      secret_key_base: secret_key_base_test
      aws:
        access_key_id: AKIAXXX
    CONTENT
    expected_pattern = /---\nsecret_key_base: #{ENCRYPTED_VALUE_PATTERN}\naws:\n  access_key_id: #{ENCRYPTED_VALUE_PATTERN}\n/

    assert_match expected_pattern, Diffcrypt::Encryptor.new(TEST_KEY).encrypt(encrypted_content)
  end
end
