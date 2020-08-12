# frozen_string_literal: true

require "rails/railtie"
require "active_record"

require "selective/version"

require "selective/collectors/ruby_coverage_collector"
require "selective/collectors/active_record/association_collector"
require "selective/collectors/active_record/attribute_reader_collector"
require "selective/collectors/active_record/attribute_writer_collector"
require "selective/collectors/action_view/asset_tag_collector"
require "selective/collectors/action_view/rendered_template_collector"
require "selective/collectors/webpacker/webpacker_app_collector"
require "selective/collectors/sprockets_asset_collector"
require "selective/collector"
require "selective/storage"

module Selective
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
        Selective::Collectors::RubyCoverageCollector,
        Selective::Collectors::ActiveRecord::AssociationCollector,
        Selective::Collectors::ActiveRecord::AttributeWriterCollector,
        Selective::Collectors::ActiveRecord::AttributeReaderCollector,
        Selective::Collectors::ActionView::RenderedTemplateCollector,
        Selective::Collectors::ActionView::AssetTagCollector,
        Selective::Collectors::Webpacker::WebpackerAppCollector
      ]
      @webpacker_app_locations = [File.join("app", "javascript")]
      @file_exclusion_check = proc { |file| false }
      @enable_check = proc { !ENV["TEST_COVERAGE_ENABLED"].nil? }
      @sprockets_asset_collector_class = Selective::Collectors::SprocketsAssetCollector
      @coverage_path = Pathname.new("/tmp/coverage-map.yml")
      @api_key = ENV["SELECTIVE_API_KEY"]
    end
  end

  class << self
    attr_accessor :collector
    attr_writer :coverage_collectors

    def configure
      @config ||= Config.new
      yield @config
    end

    def config
      @config ||= Config.new
    end

    def initialize_collectors
      if enabled?
        @collector = Selective::Collector.new(config)

        initialize_rspec_hooks
      end
    end

    def initialize_rspec_hooks
      RSpec.configure do |config|
        config.before(:example) { Selective.collector.start_recording_code_coverage }
        config.after(:example) { |example| Selective.collector.write_code_coverage_artifact(example) }
        config.after(:suite) { |suite| Selective.collector.finalize(suite) }
      end
    end

    def coverage_collectors
      @collector.coverage_collectors
    end

    def start_coverage
      if enabled?
        coverage_collectors.values.each do |coverage_collector|
          coverage_collector.on_start
        end
      end
    end

    def enabled?
      Selective.config.enable_check.call
    end

    def exclude_file?(file)
      Selective.config.file_exclusion_check.call(file)
    end
  end
end
