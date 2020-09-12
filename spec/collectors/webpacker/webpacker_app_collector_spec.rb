require "spec_helper"

RSpec.describe Selective::Collectors::Webpacker::WebpackerAppCollector do
  module WebpackerHelperDummy
    include DummyHelpers

    def javascript_packs_with_chunks_tag(*names, **options)
      if Selective.call_dummy?
        find_proper_method("Webpacker::Helper#javascript_packs_with_chunks_tag", method(__method__).super_method, names, options)
      else
        super
      end
    end
  end

  let(:dummy_js_dir) { "spec/dummy/app/javascript" }
  let(:asset_glob) { "#{dummy_js_dir}/foo/src/**.{scss,css,js}" }
  let(:package_glob) { "#{dummy_js_dir}/foo/package*.json" }
  let(:collector) { Selective.coverage_collectors[described_class] }

  describe "#add_covered_globs" do
    context "when selective is disabled" do
      let(:view) { DummyView.new(::ActionView::LookupContext.new([]), {}) }

      before do
        allow(Selective::Collectors::Webpacker::WebpackerAppCollector).to receive(:new) do
          ActiveSupport.on_load(:action_view) do
            prepend WebpackerHelperDummy
          end
        end

        allow(Selective).to receive(:report_callgraph?).and_return true
        allow(Selective).to receive(:call_dummy?).and_return true
        allow(Selective).to receive(:initialize_rspec_reporting_hooks)
        Selective.initialize_collectors
      end

      it "is not called" do
        expect_any_instance_of(::Webpacker::Helper).to receive(:javascript_packs_with_chunks_tag)
        view.extend(::Webpacker::Helper)
        view.render(inline: '<% javascript_packs_with_chunks_tag "foo" %>')
      end
    end

    context "when selective is enabled", :full_setup do
      let(:view) { DummyView.new(::ActionView::LookupContext.new([]), {}) }

      before do
        allow(Selective).to receive(:report_callgraph?).and_return true
        allow(Selective).to receive(:initialize_rspec_reporting_hooks)
        allow_any_instance_of(Selective::Config).to receive(:webpacker_app_locations).and_return([dummy_js_dir])

        Selective.initialize_collectors
        Selective.start_coverage
      end

      it "is called" do
        expect(collector).to receive(:add_covered_globs).with(asset_glob, package_glob)
        view.render(inline: '<% javascript_packs_with_chunks_tag "foo" %>')
      end

      it "adds globs to @covered_globs" do
        view.render(inline: '<% javascript_packs_with_chunks_tag "foo" %>')
        expect(collector.instance_variable_get("@covered_globs")).to eq(Set.new([asset_glob, package_glob]))
      end
    end
  end

  describe "#covered_files" do
    let(:view) { DummyView.new(::ActionView::LookupContext.new([]), {}) }

    before do
      allow(Selective).to receive(:report_callgraph?).and_return true
      allow(Selective).to receive(:initialize_rspec_reporting_hooks)
      allow_any_instance_of(Selective::Config).to receive(:webpacker_app_locations).and_return([dummy_js_dir])

      Selective.initialize_collectors
      Selective.start_coverage
    end

    it "adds metadata coverage data" do
      view.render(inline: '<% javascript_packs_with_chunks_tag "foo" %>')

      expect(collector.covered_files).to eq(asset_glob => {glob: true}, package_glob => {glob: true})
    end
  end
end
