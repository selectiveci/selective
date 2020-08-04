# frozen_string_literal: true

lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "selective/version"

Gem::Specification.new do |spec|
  spec.name = "selective"
  spec.version = Selective::VERSION
  spec.authors = ["Hint Media, Inc"]

  spec.summary = "Tools for collecting code coverage from tests"
  spec.description = "Tools for collecting code coverage from tests"

  spec.files = spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "railties", "< 7"
  spec.add_dependency "activerecord", "< 7"
  spec.add_development_dependency "bundler", "~> 2.1"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "standard"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "pry-byebug"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "factory_bot"
  spec.add_development_dependency "sqlite3"
  spec.add_development_dependency "webpacker", "4.0.1"
end
