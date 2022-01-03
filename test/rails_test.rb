# frozen_string_literal: true

require 'test_helper'
require 'bundler'

require 'open3'

RAILS_VERSIONS = %w[
  6.0.4.4
  6.1.4.4
  7.0.0
].freeze

RAILS_FLAGS = %w[
  --api
  --skip-action-cable
  --skip-active-storage
  --skip-bundle
  --skip-git
  --skip-javascript
  --skip-keeps
  --skip-system-test
  --skip-test
].freeze

TMP_RAILS_ROOT = File.join(__dir__, '../tmp/test')

# Helper to ensure we raise if command is not successful
def run_command(*command)
  stdout, stderr, status = Open3.capture3(*command)
  if status.success? == false
    errors = [
      "  Command Failed: #{command.join(' ')}",
      stdout.split("\n").map { |line| "    #{line}" }.join("\n"),
      stderr.split("\n").map { |line| "    #{line}" }.join("\n"),
    ]
    raise errors.join("\n")
  end

  [stdout, stderr, status]
end

class RailsTest < Minitest::Test
  def setup
    FileUtils.remove_dir(TMP_RAILS_ROOT) if Dir.exist?(TMP_RAILS_ROOT)
    FileUtils.mkdir_p(TMP_RAILS_ROOT)
  end

  RAILS_VERSIONS.each do |rails_version|
    define_method "test_that_rails_#{rails_version.gsub('.', '_')}_works" do
      Bundler.with_original_env do
        Dir.chdir(TMP_RAILS_ROOT) do
          tmp_version_root = "rails_#{rails_version.gsub('.', '_')}"
          FileUtils.remove_dir(tmp_version_root) if Dir.exist?(tmp_version_root)
          run_command('gem', 'install', 'rails', '--version', rails_version)
          run_command('rails', "_#{rails_version}_", 'new', *RAILS_FLAGS, tmp_version_root)
          Dir.chdir(tmp_version_root) do
            File.write('Gemfile', "gem 'diffcrypt', path: '../../..'", mode: 'a')
            run_command('bundle', 'install')
            stdout, _stderr, _status = run_command('bundle', 'exec', 'rails', 'r', 'puts Rails.version')
            assert_equal rails_version, stdout.strip
          end
        end
      end
    end
  end
end
