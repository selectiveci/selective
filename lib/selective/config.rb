# frozen_string_literal: true

module Selective
  class Config
    attr_accessor :api_key
    attr_accessor :backend_host
    attr_accessor :enabled_collector_classes
    attr_accessor :coverage_path
    attr_accessor :report_callgraph_check
    attr_accessor :select_tests_check
    attr_accessor :file_exclusion_check
    attr_accessor :webpacker_app_locations

    attr_reader :sprockets_asset_collector_class

    DEFAULT_COLLECTOR_CLASSES = [
      Selective::Collectors::RubyCoverageCollector,
      Selective::Collectors::ActiveRecord::AssociationCollector,
      Selective::Collectors::ActiveRecord::AttributeWriterCollector,
      Selective::Collectors::ActiveRecord::AttributeReaderCollector,
      Selective::Collectors::ActionView::RenderedTemplateCollector,
      Selective::Collectors::ActionView::AssetTagCollector,
      Selective::Collectors::Webpacker::WebpackerAppCollector
    ].freeze

    DEFAULT_BACKEND_HOST       = "https://selective-ci.herokuapp.com"
    DEFAULT_COVERAGE_PATH      = "/tmp/coverage-map.yml"
    DEFAULT_WEBPACKER_LOCATION = File.join("app", "javascript").freeze

    private_constant :DEFAULT_BACKEND_HOST
    private_constant :DEFAULT_COVERAGE_PATH

    def initialize
      @api_key = ENV.fetch("SELECTIVE_API_KEY", nil)
      @enabled_collector_classes = DEFAULT_COLLECTOR_CLASSES
      @backend_host = ENV.fetch("SELECTIVE_BACKEND_HOST") { DEFAULT_BACKEND_HOST }

      @file_exclusion_check = proc { false }
      @report_callgraph_check = proc { !ENV["SELECTIVE_REPORT_CALLGRAPH"].nil? }
      @select_tests_check = proc { !ENV["SELECTIVE_SELECT_TESTS"].nil? }
      @sprockets_asset_collector_class = Collectors::SprocketsAssetCollector
      @coverage_path = Pathname.new(DEFAULT_COVERAGE_PATH)
      @webpacker_app_locations = [DEFAULT_WEBPACKER_LOCATION]
    end
  end
end
