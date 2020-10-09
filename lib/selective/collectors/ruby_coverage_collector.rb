# frozen_string_literal: true

require "coverage"
module Selective
  module Collectors
    class RubyCoverageCollector
      attr_reader :root_path

      EXCLUDE_PATHS = %w[/spec /vendor]

      def initialize(root_path = Dir.pwd)

        Coverage.start unless Coverage.running?
        @root_path = root_path
      end

      def on_start
        @before = Coverage.peek_result
      end

      def covered_files
        after = Coverage.peek_result
        coverage = detect(after)
        {}.tap do |coverage_data|
          coverage.each do |file,|
            next if Selective.exclude_file?(file)

            coverage_data[file] = true
          end
        end
      end

      private

      attr_reader :before

      def detect(after)
        filter after.reject { |file_name, after_coverage| before[file_name].eql?(after_coverage) }.keys
      end

      def filter(paths)
        paths.select do |file_name|
          file_name.start_with?(root_path) && exclude_paths.none? { |p| file_name.start_with?(p) }
        end
      end

      def exclude_paths
        @exclude_paths ||= EXCLUDE_PATHS.map { |p| root_path + p }
      end
    end
  end
end
