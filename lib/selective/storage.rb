# frozen_string_literal: true

require 'yaml'

module Selective
  class Storage
    # Exception class for missing map files
    class NoFilesFoundError < StandardError; end

    # YAML persistence adapter for execution map storage
    attr_reader :path

    class << self
      # Loads map from given path
      #
      # @param [String] path to map
      # @return [Crystalball::ExecutionMap]
      def load(path)
        raise NoFilesFoundError, "No file exists #{path}" unless path.exist?

        examples = path.read.split("---\n").reject(&:empty?).map do |yaml|
          YAML.safe_load(yaml, [Symbol])
        end

        examples.inject(&:merge!)
      end

      private
    end

    # @param [String] path to store execution map
    def initialize(path)
      @path = path
    end

    # Removes storage file
    def clear!
      path.delete if path.exist?
    end

    # Writes data to storage file
    #
    # @param [Hash] data to write to storage file
    def dump(data)
      path.dirname.mkpath
      path.open('a') { |f| f.write YAML.dump(data) }
    end
  end
end