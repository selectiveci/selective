# frozen_string_literal: true

# Set up gems listed in the Gemfile.
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../Gemfile', __dir__)

require 'bundler/setup' if File.exist?(ENV['BUNDLE_GEMFILE'])

# require 'rails/all'
require 'active_record/railtie'

Bundler.reset!
Bundler.require(*Rails.groups(assets: %w[development test]))

require "selective"

`mysql -h 127.0.0.1 -uroot -e "DROP DATABASE IF EXISTS Selectivedummy_test; CREATE DATABASE IF NOT EXISTS Selectivedummy_test;"`

module SelectiveDummyApp
  class Application < Rails::Application
    config.root = File.expand_path('../', __dir__)

    def name
      "Selectivedummy"
    end
  end
end

require_relative '../engines/dummy_engine/lib/dummy_engine'
