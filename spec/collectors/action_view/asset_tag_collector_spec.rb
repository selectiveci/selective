require "spec_helper"

RSpec.describe Selective::Collectors::ActionView::AssetTagCollector do
  before do
    allow(Selective).to receive(:report_callgraph?).and_return true
    allow(Selective).to receive(:initialize_rspec_reporting_hooks)
    Selective.initialize_collectors
    Selective.start_coverage
  end

  before(:each, :init_view_and_add_assets) do
    view.extend(Selective::Collectors::ActionView::AssetTagHelper)

    view.render(inline: "<% javascript_include_tag 'foo' %>")
    view.render(inline: "<% stylesheet_link_tag 'foo' %>")
  end

  describe "#initialize" do
    it "prepends helper module" do
      expect(DummyView.ancestors).to include(Selective::Collectors::ActionView::AssetTagHelper)
    end
  end

  describe "#on_start" do
    let(:collector) { Selective.coverage_collectors[described_class] }

    it "inits collection instance variable" do
      expect(collector.instance_variable_get("@covered_assets_collection")).to eql(Set.new)
    end
  end

  describe "#add_covered_assets" do
    let(:view) { DummyView.new(::ActionView::LookupContext.new([]), {}, @controller) }
    let(:covered_assets_collection) { Selective.coverage_collectors[described_class].instance_variable_get("@covered_assets_collection") }

    it "adds assets to @covered_assets_collection", :init_view_and_add_assets do
      expect(covered_assets_collection).to include("foo.css")
      expect(covered_assets_collection).to include("foo.js")
    end
  end

  describe "#covered_files" do
    let(:view) { DummyView.new(::ActionView::LookupContext.new([]), {}, @controller) }
    let(:collector) { Selective.coverage_collectors[described_class] }
    let(:sprocket_asset_double) { double }

    before do
      allow(::Rails.application).to receive(:assets).and_return("foo.css" => sprocket_asset_double)
      allow(sprocket_asset_double).to receive(:metadata).and_return(dependencies: ["bar.css", "baz.css", "nope.nada"])
    end

    it "adds assets to @covered_assets_collection", :init_view_and_add_assets do
      expect(collector.covered_files).to eql("bar.css" => {asset: true}, "baz.css" => {asset: true})
    end
  end
end
