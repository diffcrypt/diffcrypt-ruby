# frozen_string_literal: true

require 'test_helper'
require 'thor'

require_relative '../../lib/diffcrypt/cli'

class Diffcrypt::CLITest < Minitest::Test
  def test_it_extends_thor
    assert Diffcrypt::CLI < Thor
  end
end
