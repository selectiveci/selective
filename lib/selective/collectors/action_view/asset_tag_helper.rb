# frozen_string_literal: true

module Selective
  module Collectors
    module ActionView
      module AssetTagHelper
        def javascript_include_tag(*sources)
          tag_collector.add_covered_assets(*js_sources(sources))
          super
        end

        def stylesheet_link_tag(*sources)
          tag_collector.add_covered_assets(*css_sources(sources))
          super
        end

        private

        def tag_collector
          Selective.coverage_collectors.fetch(AssetTagCollector)
        end

        def sources_without_options(sources)
          sources.last.instance_of?(Hash) ? sources[0...-1] : sources
        end

        def js_sources(sources)
          sources_without_options(sources).map { |source| "#{source}.js" }
        end

        def css_sources(sources)
          sources_without_options(sources).map { |source| "#{source}.css" }
        end
      end
    end
  end
end
