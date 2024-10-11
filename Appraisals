# frozen_string_literal: true

SUPPORTED_RAILS_VERSIONS = %w[
  6.1
  7.1
  7.2
].freeze

SUPPORTED_RAILS_VERSIONS.each do |version|
  appraise "rails-#{version}" do
    gem 'rails', "~> #{version}"
  end
end
