# frozen_string_literal: true

module Selective
  class Config
    attr_accessor :api_key
    attr_accessor :enabled_collector_classes
    attr_reader :coverage_path
    attr_reader :enable_check
    attr_reader :file_exclusion_check
    attr_reader :sprockets_asset_collector_class
    attr_reader :webpacker_app_locations

    DEFAULT_COLLECTOR_CLASSES = [
      Selective::Collectors::RubyCoverageCollector,
      Selective::Collectors::ActiveRecord::AssociationCollector,
      Selective::Collectors::ActiveRecord::AttributeWriterCollector,
      Selective::Collectors::ActiveRecord::AttributeReaderCollector,
      Selective::Collectors::ActionView::RenderedTemplateCollector,
      Selective::Collectors::ActionView::AssetTagCollector,
      Selective::Collectors::Webpacker::WebpackerAppCollector
    ].freeze

    def initialize
      @enabled_collector_classes = DEFAULT_COLLECTOR_CLASSES
      @webpacker_app_locations = [File.join("app", "javascript")]
      @file_exclusion_check = proc { |file| false }
      @enable_check = proc { !ENV["TEST_COVERAGE_ENABLED"].nil? }
      @sprockets_asset_collector_class = Selective::Collectors::SprocketsAssetCollector
      @coverage_path = Pathname.new("/tmp/coverage-map.yml")
      @api_key = ENV["SELECTIVE_API_KEY"]
    end
  end
end
