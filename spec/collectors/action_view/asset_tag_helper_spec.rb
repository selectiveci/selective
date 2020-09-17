require "spec_helper"

RSpec.describe Selective::Collectors::ActionView::AssetTagHelper do
  module AssetTagHelperDummy
    def javascript_include_tag(*sources)
      super unless Selective.call_dummy?
    end

    def stylesheet_link_tag(*sources)
      super unless Selective.call_dummy?
    end
  end

  describe "#add_covered_assets" do
    let(:mock_collector) { double }
    before do
      allow(Selective).to receive(:coverage_collectors).and_return({
        Selective::Collectors::ActionView::AssetTagCollector => mock_collector
      })

      Selective.start_coverage
    end

    context "when selective is disabled" do
      let(:view) { DummyView.new(::ActionView::LookupContext.new([]), {}) }

      before do
        allow(Selective::Collectors::ActionView::AssetTagCollector).to receive(:new) do
          ActiveSupport.on_load(:action_view) do
            prepend AssetTagHelperDummy
          end
        end

        allow(Selective).to receive(:report_callgraph?).and_return true
        allow(Selective).to receive(:call_dummy?).and_return true
        allow(Selective).to receive(:initialize_rspec_reporting_hooks)
        Selective.initialize_collectors
      end

      it "is not called" do
        expect(mock_collector).not_to receive(:add_covered_globs)

        view.render(inline: '<% javascript_include_tag "foo", extname: false %>')
        view.render(inline: '<% stylesheet_link_tag "foo" %>')
      end
    end

    context "when selective is enabled" do
      let(:view) { DummyView.new(::ActionView::LookupContext.new([]), {}) }

      it "is called" do
        view.extend(Selective::Collectors::ActionView::AssetTagHelper)

        expect(mock_collector).to receive(:add_covered_assets).with("foo.css")
        expect(mock_collector).to receive(:add_covered_assets).with("foo.js")

        view.render(inline: '<% javascript_include_tag "foo", extname: false %>')
        view.render(inline: '<% stylesheet_link_tag "foo" %>')
      end
    end
  end
end
