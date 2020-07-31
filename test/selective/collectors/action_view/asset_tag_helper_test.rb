# frozen_string_literal: true

require 'test_helper'

module Selective
  module Collectors
    module ActionView
      class AssetTagHelperTest < ActiveSupport::TestCase
        def setup
          Selective.stubs(:single_test_coverage_enabled?).returns(true)
          Selective.start_coverage

          @mock_collector = mock
          Selective.coverage_collectors = {
            AssetTagCollector => @mock_collector
          }
        end

        def test_render__javascript_include_tag__registers_covered_asset
          @mock_collector.expects(:add_covered_assets).never
          view = DummyView.new(::ActionView::LookupContext.new([]), {})
          view.render(inline: '<% javascript_include_tag "foo" %>')

          @mock_collector.expects(:add_covered_assets).with('foo.js')
          view.extend(Selective::Collectors::ActionView::AssetTagHelper)
          view.render(inline: '<% javascript_include_tag "foo" %>')
        end

        def test_render__stylesheet_include_tag__registers_covered_asset
          @mock_collector.expects(:add_covered_assets).never
          view = DummyView.new(::ActionView::LookupContext.new([]), {})
          view.render(inline: '<% stylesheet_link_tag "foo" %>')

          @mock_collector.expects(:add_covered_assets).with('foo.css')
          view.extend(Selective::Collectors::ActionView::AssetTagHelper)
          view.render(inline: '<% stylesheet_link_tag "foo" %>')
        end
      end
    end
  end
end
