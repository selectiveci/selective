# frozen_string_literal: true

module Selective
  module Collectors
    class SprocketsAssetCollector

      ASSET_EXTENSIONS = [".js", ".es6", ".css", ".scss"].freeze

      def initialize(asset_path)
        @asset_path = asset_path
      end

      def collect
        asset = Rails.application.assets[asset_path]
        # It's not clear why an asset would not be found in the cache.  It happens but it seems to happen rarely and repeatably
        # If there is a bug with assets changes not triggering a test to run, look here to see if the asset was not included
        # as a dependency because it was not found in the cache

        if asset.nil?
          puts "Skipping asset #{asset_path} because it was not found in the cache"
          return []
        end

        asset.metadata.fetch(:dependencies).select { |d| d.ends_with?(*ASSET_EXTENSIONS) }
      end

      private

      attr_reader :asset_path
    end
  end
end
