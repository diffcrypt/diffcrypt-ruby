# frozen_string_literal: true

require 'test_helper'

class DiffcryptTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Diffcrypt::VERSION
  end

  def test_it_defines_root_module
    assert defined?(Diffcrypt)
  end

  def test_it_defines_encryptor_when_included
    assert defined?(Diffcrypt::Encryptor)
  end
end
