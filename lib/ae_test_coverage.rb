# frozen_string_literal: true

require 'rails/railtie'
require 'active_record'

require 'ae_test_coverage/version'

require 'ae_test_coverage/collectors/ruby_coverage_collector'
require 'ae_test_coverage/collectors/active_record/association_collector'
require 'ae_test_coverage/collectors/active_record/attribute_reader_collector'
require 'ae_test_coverage/collectors/active_record/attribute_writer_collector'
require 'ae_test_coverage/collectors/action_view/asset_tag_collector'
require 'ae_test_coverage/collectors/action_view/rendered_template_collector'
require 'ae_test_coverage/collectors/webpacker/webpacker_app_collector'
require 'ae_test_coverage/collectors/sprockets_asset_collector'
require 'ae_test_coverage/collector'
require 'ae_test_coverage/storage'

module AeTestCoverage
  class Config
    attr_accessor :enabled_collector_classes
    attr_accessor :webpacker_app_locations
    attr_accessor :file_exclusion_check
    attr_accessor :enable_check
    attr_accessor :sprockets_asset_collector_class
    attr_accessor :coverage_path
    attr_accessor :api_key

    def initialize
      @enabled_collector_classes = [
        AeTestCoverage::Collectors::RubyCoverageCollector,
        AeTestCoverage::Collectors::ActiveRecord::AssociationCollector,
        AeTestCoverage::Collectors::ActiveRecord::AttributeWriterCollector,
        AeTestCoverage::Collectors::ActiveRecord::AttributeReaderCollector,
        AeTestCoverage::Collectors::ActionView::RenderedTemplateCollector,
        AeTestCoverage::Collectors::ActionView::AssetTagCollector,
        AeTestCoverage::Collectors::Webpacker::WebpackerAppCollector
      ]
      @webpacker_app_locations = [File.join('app', 'javascript')]
      @file_exclusion_check = Proc.new { |file| false }
      @enable_check = Proc.new { !ENV['TEST_COVERAGE_ENABLED'].nil? }
      @sprockets_asset_collector_class = AeTestCoverage::Collectors::SprocketsAssetCollector
      @coverage_path = Pathname.new('/tmp/coverage-map.yml')
      @api_key = ENV['AE_TEST_COVERAGE_API_KEY']
    end
  end

  class << self
    attr_accessor :single_test_coverage_enabled, :coverage_collectors, :collector

    def configure
      @config ||= Config.new
      yield @config
    end

    def config
      @config ||= Config.new
    end

    def initialize_collectors
      if enabled?
        @collector = AeTestCoverage::Collector.new(config)

        RSpec.configure do |config|
          config.before(:example) { AeTestCoverage.collector.start_recording_code_coverage }
          config.after(:example) { |example| AeTestCoverage.collector.write_code_coverage_artifact(example) }

          config.after(:suite) { |suite| AeTestCoverage.collector.finalize(suite) }
        end
      end
    end

    def coverage_collectors
      @collector.coverage_collectors
    end

    def start_coverage
      if self.enabled?
        coverage_collectors.values.each do |coverage_collector|
          coverage_collector.on_start
        end
      end
    end

    def enabled?
      AeTestCoverage.config.enable_check.call
    end

    def exclude_file?(file)
      AeTestCoverage.config.file_exclusion_check.call(file)
    end
  end
end
