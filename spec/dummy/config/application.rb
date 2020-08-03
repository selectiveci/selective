# frozen_string_literal: true

# Set up gems listed in the Gemfile.
ENV["BUNDLE_GEMFILE"] ||= File.expand_path("../../Gemfile", __dir__)

require "bundler/setup" if File.exist?(ENV["BUNDLE_GEMFILE"])

require "active_record/railtie"

Bundler.reset!
# must load development here because gemspec dependencies
# are loaded as development gems
Bundler.require(:default, :test, :development, :assets)

module SelectiveDummyApp
  class Application < Rails::Application
    config.root = File.expand_path("../", __dir__)

    def name
      "SelectiveDummy"
    end
  end
end

require_relative "../engines/dummy_engine/lib/dummy_engine"
