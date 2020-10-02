# frozen_string_literal: true

require "rails/railtie"
require "active_record"

require "selective/version"

require_relative "selective/collectors/ruby_coverage_collector"
require_relative "selective/collectors/active_record/association_collector"
require_relative "selective/collectors/active_record/attribute_reader_collector"
require_relative "selective/collectors/active_record/attribute_writer_collector"
require_relative "selective/collectors/action_view/asset_tag_collector"
require_relative "selective/collectors/action_view/rendered_template_collector"
require_relative "selective/collectors/webpacker/webpacker_app_collector"
require_relative "selective/collectors/sprockets_asset_collector"
require_relative "selective/collector"
require_relative "selective/selector"
require_relative "selective/config"
require_relative "selective/storage"
require_relative "selective/api"

module Selective
  class << self
    attr_accessor :collector
    attr_accessor :selected_tests
    attr_accessor :skipped_tests
    attr_writer :coverage_collectors

    delegate :coverage_collectors, to: :collector

    def config
      @config ||= Config.new
    end

    def start(&block)
      if block
        @config ||= Config.new
        yield @config
      end

      initialize_collectors if report_callgraph?
      initialize_test_selection if select_tests?
    end

    def initialize_collectors
      @collector = Collector.new(config)
      initialize_rspec_reporting_hooks if defined?(RSpec)
      initialize_minitest_reporting_hooks if defined?(Minitest)
    end

    def initialize_rspec_reporting_hooks
      RSpec.configure do |config|
        config.around(:example) do |example|
          Selective.collector.start_recording_code_coverage
          example.run
          Selective.collector.write_code_coverage_artifact(example.id)
        end

        config.after(:suite) do
          Selective.collector.finalize
        end
      end
    end

    def initialize_minitest_reporting_hooks
      require_relative 'selective/minitest/report_callgraph'
    end

    def initialize_test_selection
      @selected_tests = []
      @skipped_tests = []
      initialize_rspec_test_selection if defined?(RSpec)
      initialize_minitest_test_selection if defined?(Minitest)
    end

    def initialize_rspec_test_selection
      RSpec.configure do |config|
        config.before(:suite) do |suite|
          Selective.selected_tests = Selective::Selector.tests_from_diff
        end

        config.around(:example) do |example|
          if Selective.selected_tests.blank? || (Selective.selected_tests & [example.id, example.file_path]).any?
            example.run
          else
            Selective.skipped_tests << example.id
          end
        end

        config.after(:suite) do |suite|
          suite.reporter.examples.delete_if { |e| Selective.skipped_tests.include?(e.id) }
          suite.reporter.pending_examples.delete_if { |e| Selective.skipped_tests.include?(e.id) }
        end
      end
    end

    def initialize_minitest_test_selection
      require_relative 'selective/minitest/test_selection'
    end

    def start_coverage
      if report_callgraph?
        coverage_collectors.values.each do |coverage_collector|
          coverage_collector.on_start
        end
      end
    end

    def report_callgraph?
      config.report_callgraph_check.call
    end

    def select_tests?
      config.select_tests_check.call
    end

    def exclude_file?(file)
      config.file_exclusion_check.call(file)
    end
  end
end
