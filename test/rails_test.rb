# frozen_string_literal: true

require 'test_helper'
require 'bundler'

require 'open3'

class RailsTest < Minitest::Test
  def test_it_initialises_with_rails_6_0
    tmp_root = File.join(__dir__, '../tmp/test')
    FileUtils.remove_dir(tmp_root)
    FileUtils.mkdir_p(tmp_root) unless Dir.exist?(tmp_root)
    Bundler.with_original_env do
      Dir.chdir(tmp_root) do
        `gem install rails --version 6.0.4.4`
        `rails _6.0.4.4_ new --api --skip-git --skip-keeps --skip-active-storage --skip-action-cable --skip-javascript --skip-system-test --skip-test rails_6_0`
        Dir.chdir('rails_6_0') do
          File.write('Gemfile', "gem 'diffcrypt', path: '../../..'", mode: 'a')
          stdout, _stderr, status = Open3.capture3('bundle', 'exec', 'rails', 'r', 'puts Rails.version')
          assert_equal '6.0.4.4', stdout.strip
          assert_equal 0, status
        end
      end
    end
  end

  def test_it_initialises_with_rails_6_1
    tmp_root = File.join(__dir__, '../tmp/test')
    FileUtils.remove_dir(tmp_root)
    FileUtils.mkdir_p(tmp_root) unless Dir.exist?(tmp_root)
    Bundler.with_original_env do
      Dir.chdir(tmp_root) do
        `gem install rails --version 6.1.4.4`
        `rails _6.1.4.4_ new --api --skip-git --skip-keeps --skip-active-storage --skip-action-cable --skip-javascript --skip-system-test --skip-test rails_6_1`
        Dir.chdir('rails_6_1') do
          File.write('Gemfile', "gem 'diffcrypt', path: '../../..'", mode: 'a')
          stdout, _stderr, status = Open3.capture3('bundle', 'exec', 'rails', 'r', 'puts Rails.version')
          assert_equal '6.1.4.4', stdout.strip
          assert_equal 0, status
        end
      end
    end
  end

  def test_it_initialises_with_rails_7_0
    tmp_root = File.join(__dir__, '../tmp/test')
    FileUtils.remove_dir(tmp_root)
    FileUtils.mkdir_p(tmp_root) unless Dir.exist?(tmp_root)
    Bundler.with_original_env do
      Dir.chdir(tmp_root) do
        `gem install rails --version 7.0.0`
        `rails _7.0.0_ new --api --skip-git --skip-keeps --skip-active-storage --skip-action-cable --skip-javascript --skip-system-test --skip-test rails_7_0`
        Dir.chdir('rails_7_0') do
          File.write('Gemfile', "gem 'diffcrypt', path: '../../..'", mode: 'a')
          stdout, _stderr, status = Open3.capture3('bundle', 'exec', 'rails', 'r', 'puts Rails.version')
          assert_equal '7.0.0', stdout.strip
          assert_equal 0, status
        end
      end
    end
  end
end
