# frozen_string_literal: true

require 'diffcrypt/rails/application_helper'

module Diffcrypt
  class Railtie < ::Rails::Railtie
    railtie_name :diffcrypt

    rake_tasks do
      path = ::File.expand_path(__dir__)
      ::Dir.glob("#{path}/tasks/**/*.rake").each { |f| load f }
    end
  end
end
