# frozen_string_literal: true

require 'test_helper'

# Since the encrypted values use openssl and are non-deterministic, we can never know the
# actual value to test against. All we can do is ensure the value is in the correct format
# for the encrypted content, which verifies it's not in the original state
ENCRYPTED_VALUE_PATTERN = %(['"]?([a-z0-9A-Z=/+]+)\-\-([a-z0-9A-Z=/+]+)\-\-([a-z0-9A-Z=/+]+)['"]?)

class Diffcrypt::EncryptorTest < Minitest::Test
  def test_it_includes_client_info_at_root
    content = "---\nkey: value"
    expected_pattern = /---\nclient: diffcrypt-#{Diffcrypt::VERSION}\ncipher: #{Diffcrypt::Encryptor::DEFAULT_CIPHER}\ndata:\n  key: #{ENCRYPTED_VALUE_PATTERN}\n/
    assert_match expected_pattern, Diffcrypt::Encryptor.new(TEST_KEY_256).encrypt(content)
  end

  def test_it_includes_cipher_when_not_default
    content = "---\nkey: value"
    expected_pattern = /---\nclient: diffcrypt-#{Diffcrypt::VERSION}\ncipher: aes-128-gcm\ndata:\n  key: #{ENCRYPTED_VALUE_PATTERN}\n/
    assert_match expected_pattern, Diffcrypt::Encryptor.new(TEST_KEY_128, cipher: 'aes-128-gcm').encrypt(content)
  end

  def test_it_decrypts_root_values
    encrypted_content = <<~CONTENT
      data:
        secret_key_base: 88Ry6HESUoXBr6QUFXmni9zzfCIYt9qGNFvIWFcN--4xoecI5mqbNRBibI--62qPJbkzzh5h8lhFEFOSaQ==
    CONTENT
    expected = <<~CONTENT
      ---
      secret_key_base: secret_key_base_test
    CONTENT

    assert_equal Diffcrypt::Encryptor.new(TEST_KEY_128, cipher: 'aes-128-gcm').decrypt(encrypted_content), expected
  end

  def test_it_encrypts_root_values
    content = <<~CONTENT
      ---
      secret_key_base: secret_key_base_test
    CONTENT
    expected_pattern = /---\nsecret_key_base: #{ENCRYPTED_VALUE_PATTERN}\n/

    assert_match expected_pattern, Diffcrypt::Encryptor.new(TEST_KEY_128, cipher: 'aes-128-gcm').encrypt_data(content).to_yaml
  end

  def test_it_decrypts_nested_structures
    encrypted_content = <<~CONTENT
      data:
        array:
        - item1: 7HJjrwQ6KqH+jvu1pOZGqQ==--E2ipnCNCszD6oixM--QZapG/8wrPtwbUVDe9evsw==
          subitem: oNNLBGwL45VvOv7elkRTHZTcNQ==--iFBc53R3F26zsvTK--6iEtqH7TR7TSS6fJOHwfPg==
        - item2: IvwdxcAV+38MvNsKYdNCEg==--6y7Aj4nmFLOTGrx3--rRH8ni3yks2eid91jde2hg==
        secret_key_base: 88Ry6HESUoXBr6QUFXmni9zzfCIYt9qGNFvIWFcN--4xoecI5mqbNRBibI--62qPJbkzzh5h8lhFEFOSaQ==
        aws:
          access_key_id: Ot/uCTEL+8kp61EPctnxNlg=--Be6sg7OdvjZlfxgR--7qRbbf0lA4VgjnUGUrrFwg==

    CONTENT
    expected = <<~CONTENT
      ---
      array:
      - item1: value1
        subitem: value sub
      - item2: value2
      secret_key_base: secret_key_base_test
      aws:
        access_key_id: AKIAXXX
    CONTENT

    assert_equal Diffcrypt::Encryptor.new(TEST_KEY_128, cipher: 'aes-128-gcm').decrypt(encrypted_content), expected
  end

  def test_it_encrypts_nested_structures
    content = <<~CONTENT
      ---
      secret_key_base: secret_key_base_test
      aws:
        access_key_id: AKIAXXX
      array:
      - item1: value1
        subitem: value sub
      - item2: value2
    CONTENT
    expected_pattern = /---\narray:\n- item1: #{ENCRYPTED_VALUE_PATTERN}\n  subitem: #{ENCRYPTED_VALUE_PATTERN}\n- item2: #{ENCRYPTED_VALUE_PATTERN}\naws:\n  access_key_id: #{ENCRYPTED_VALUE_PATTERN}\nsecret_key_base: #{ENCRYPTED_VALUE_PATTERN}/

    assert_match expected_pattern, Diffcrypt::Encryptor.new(TEST_KEY_128, cipher: 'aes-128-gcm').encrypt_data(content).to_yaml
  end

  # Verifies that a change to one key does not cause the encrypted values for other keys to be recomputed
  # Mainly used in conjunction with rails credentials editor
  def test_it_only_updates_changed_values
    original_encrypted_content = "---\ndata:\n  secret_key_base_1: 88Ry6HESUoXBr6QUFXmni9zzfCIYt9qGNFvIWFcN--4xoecI5mqbNRBibI--62qPJbkzzh5h8lhFEFOSaQ==\naws:\n    secret_access_key: 88Ry6HESUoXBr6QUFXmni9zzfCIYt9qGNFvIWFcN--4xoecI5mqbNRBibI--62qPJbkzzh5h8lhFEFOSaQ==\n"
    updated_content = "---\nsecret_key_base_1: secret_key_base_test\naws:\n  secret_access_key: secret_access_key_2"
    expected_pattern = /---\naws:\n  secret_access_key: #{ENCRYPTED_VALUE_PATTERN}\nsecret_key_base_1: 88Ry6HESUoXBr6QUFXmni9zzfCIYt9qGNFvIWFcN--4xoecI5mqbNRBibI--62qPJbkzzh5h8lhFEFOSaQ==\n/

    assert_match expected_pattern, Diffcrypt::Encryptor.new(TEST_KEY_128, cipher: 'aes-128-gcm').encrypt_data(updated_content, original_encrypted_content).to_yaml
  end

  def test_it_only_updates_changed_values_for_arrays
    original_encrypted_content = "---\ndata:\n  array:\n  - item1: 7HJjrwQ6KqH+jvu1pOZGqQ==--E2ipnCNCszD6oixM--QZapG/8wrPtwbUVDe9evsw==\n  - item2: IvwdxcAV+38MvNsKYdNCEg==--6y7Aj4nmFLOTGrx3--rRH8ni3yks2eid91jde2hg==\n"
    updated_content = "---\narray:\n  - item1: value1\n  - item2: value2"
    expected_pattern = %r{---\narray:\n- item1: 7HJjrwQ6KqH\+jvu1pOZGqQ==--E2ipnCNCszD6oixM--QZapG/8wrPtwbUVDe9evsw==\n- item2: IvwdxcAV\+38MvNsKYdNCEg==--6y7Aj4nmFLOTGrx3--rRH8ni3yks2eid91jde2hg==\n}

    assert_match expected_pattern, Diffcrypt::Encryptor.new(TEST_KEY_128, cipher: 'aes-128-gcm').encrypt_data(updated_content, original_encrypted_content).to_yaml
  end

  def test_it_assumes_changed_when_no_original_value
    original_encrypted_content = "---\ndata:\n  secret_key_base_1: 88Ry6HESUoXBr6QUFXmni9zzfCIYt9qGNFvIWFcN--4xoecI5mqbNRBibI--62qPJbkzzh5h8lhFEFOSaQ==\n"
    updated_content = "---\nsecret_key_base_1: secret_key_base_test\naws:\n  access_key_id: new_value\n"
    expected_pattern = /---\naws:\n  access_key_id: #{ENCRYPTED_VALUE_PATTERN}\nsecret_key_base_1: 88Ry6HESUoXBr6QUFXmni9zzfCIYt9qGNFvIWFcN--4xoecI5mqbNRBibI--62qPJbkzzh5h8lhFEFOSaQ==\n/

    assert_match expected_pattern, Diffcrypt::Encryptor.new(TEST_KEY_128, cipher: 'aes-128-gcm').encrypt_data(updated_content, original_encrypted_content).to_yaml
  end
end
