# frozen_string_literal: true

require_relative 'lib/diffcrypt/version'

Gem::Specification.new do |spec|
  spec.name          = 'diffcrypt'
  spec.version       = Diffcrypt::VERSION
  spec.authors       = ['Marc Qualie']
  spec.email         = ['marc@marcqualie.com']

  spec.summary       = 'Diffable encrypted configuration files'
  spec.description   = 'Diffable encrypted configuration files that can be safely committed into a git repository'
  spec.homepage      = 'https://github.com/diffcrypt/diffcrypt-ruby'
  spec.license       = 'MIT'
  spec.required_ruby_version = Gem::Requirement.new('>= 3.0.0')

  # spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/diffcrypt/diffcrypt-ruby'
  # spec.metadata['changelog_uri'] = "TODO: Put your gem's CHANGELOG.md URL here."

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(::File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir = 'bin'
  spec.executables = %w[diffcrypt]
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'activesupport', '>= 6.0', '< 9.0'
  spec.add_runtime_dependency 'thor', '>= 0.20', '< 2'
  spec.metadata['rubygems_mfa_required'] = 'true'
end
