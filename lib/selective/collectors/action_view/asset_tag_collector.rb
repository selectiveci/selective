# frozen_string_literal: true

require "selective/collectors/action_view/asset_tag_helper"

module Selective
  module Collectors
    module ActionView
      class AssetTagCollector
        def initialize
          ActiveSupport.on_load(:action_view) do
            prepend AssetTagHelper
          end
        end

        def on_start
          @covered_assets_collection = Set.new
        end

        def add_covered_assets(*assets)
          @covered_assets_collection&.merge(assets)
        end

        def covered_files
          test_assets = Set.new(
            @covered_assets_collection.flat_map { |asset_path|
              Selective.config.sprockets_asset_collector_class.new(asset_path).collect
            }
          )
          {}.tap do |coverage_data|
            test_assets.to_a.map do |asset_uri|
              coverage_data[URI.parse(asset_uri).path] = {asset: true}
            end
          end
        end
      end
    end
  end
end
