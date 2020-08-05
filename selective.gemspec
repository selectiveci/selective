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

  spec.files = spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
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
end
