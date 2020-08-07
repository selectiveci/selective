require "factory_bot"
require 'simplecov'

SimpleCov.start

ENV["RAILS_ENV"] = "test"

# Load dummy application
require File.expand_path("dummy/config/environment.rb", File.dirname(__FILE__))

# Load support files
Dir[File.expand_path("support/**/*.rb", File.dirname(__FILE__))].sort.each { |f| require(f) }

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods

  config.before(:suite) do
    FactoryBot.find_definitions
  end

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
end

Selective.module_eval do
  def self.call_dummy?
    false
  end
end
