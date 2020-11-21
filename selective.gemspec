# frozen_string_literal: true

lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "selective/version"

Gem::Specification.new do |spec|
  spec.name = "selective"
  spec.version = Selective::VERSION
  spec.authors = ["Hint Media, Inc"]
  spec.licenses = ["MIT"]
  spec.homepage = "http://github.com/selectiveci/selective"

  spec.summary = "Tools for collecting code coverage from tests"
  spec.description = "Tools for collecting code coverage and sending them to SelectiveCI"

  spec.files = Dir["lib/**/*"]
  spec.require_paths = ["lib"]

  spec.add_dependency "railties", "< 7"
  spec.add_dependency "activerecord", "< 7"
  spec.add_development_dependency "bundler", "~> 2.1"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "standard", "~> 0.4"
  spec.add_development_dependency "simplecov", "~> 0.17.0"
  spec.add_development_dependency "pry", "~> 0.13"
  spec.add_development_dependency "pry-byebug", "~> 3.9"
  spec.add_development_dependency "rspec", "~> 3.9"
  spec.add_development_dependency "factory_bot", "~> 6.1"
  spec.add_development_dependency "sqlite3", "~> 1.4"
  spec.add_development_dependency "webpacker", "4.0.1"
  spec.add_development_dependency "webmock", "~> 3.8.3"
  spec.add_development_dependency "rspec_junit_formatter", "~> 0.4.1"
  spec.add_development_dependency "bump", "~> 0.9.0"
  spec.add_development_dependency "minitest", "~> 5.14"
  spec.add_development_dependency "cucumber-rails", "~> 2.2.0"
end
