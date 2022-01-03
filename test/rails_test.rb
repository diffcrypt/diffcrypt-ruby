# frozen_string_literal: true

require 'test_helper'
require 'bundler'

require 'open3'

RAILS_VERSIONS = %w[
  6.0.4.4
  6.1.4.4
  7.0.0
].freeze

# Helper to ensure we raise if command is not successful
def run_command(*command)
  puts "  > #{command.join(' ')}" if ENV['DEBUG']
  stdout, stderr, status = Open3.capture3(*command)
  puts stdout.split("\n").map { |line| "    #{line}" }.join("\n") if ENV['DEBUG']
  raise stderr unless status.success?

  [stdout, stderr, status]
end

class RailsTest < Minitest::Test
  RAILS_VERSIONS.each do |rails_version|
    define_method "test_that_rails_#{rails_version.gsub('.', '_')}_works" do
      tmp_root = File.join(__dir__, '../tmp/test')
      FileUtils.mkdir_p(tmp_root) unless Dir.exist?(tmp_root)
      Bundler.with_original_env do
        Dir.chdir(tmp_root) do
          tmp_version_root = "rails_#{rails_version.gsub('.', '_')}"
          FileUtils.remove_dir(tmp_version_root) if Dir.exist?(tmp_version_root)
          run_command('gem', 'install', 'rails', '--version', rails_version)
          run_command('rails', "_#{rails_version}_", 'new', '--api', '--skip-git', '--skip-keeps', '--skip-bundle', '--skip-active-storage', '--skip-action-cable', '--skip-javascript', '--skip-system-test', '--skip-test', tmp_version_root)
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
