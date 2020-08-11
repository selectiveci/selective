require "spec_helper"

RSpec.describe Selective::Collectors::ActionView::AssetTagHelper do
  describe "#add_covered_assets" do
    before do
      @mock_collector = double
      allow(Selective).to receive(:coverage_collectors).and_return({
        Selective::Collectors::ActionView::AssetTagCollector => @mock_collector
      })

      Selective.start_coverage
    end

    context "when selective is not enabled" do
      let(:view) { DummyView.new(::ActionView::LookupContext.new([]), {}) }

      it "is not called" do
        expect(@mock_collector).not_to receive(:add_covered_globs)

        view.render(inline: '<% javascript_include_tag "foo" %>')
        view.render(inline: '<% stylesheet_link_tag "foo" %>')
      end
    end

    context "when selective is enabled" do
      let(:view) { DummyView.new(::ActionView::LookupContext.new([]), {}) }

      it "is not called" do
        view.extend(Selective::Collectors::ActionView::AssetTagHelper)

        expect(@mock_collector).to receive(:add_covered_assets).with("foo.css")
        expect(@mock_collector).to receive(:add_covered_assets).with("foo.js")

        view.render(inline: '<% javascript_include_tag "foo" %>')
        view.render(inline: '<% stylesheet_link_tag "foo" %>')
      end
    end
  end
end
