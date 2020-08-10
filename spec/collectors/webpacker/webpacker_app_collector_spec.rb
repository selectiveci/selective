require "spec_helper"

RSpec.describe Selective::Collectors::Webpacker::WebpackerAppCollector do
  class DummyView < ActionView::Base
  end

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

  describe "#add_covered_globs" do
    context "when selective is disabled" do
      let(:view) { DummyView.new(::ActionView::LookupContext.new([]), {}) }

      before do
        allow_any_instance_of(Selective::Collectors::Webpacker::WebpackerAppCollector).to receive(:initialize) do
          ActiveSupport.on_load(:action_view) do
            prepend WebpackerHelperDummy
          end
        end

        allow(Selective).to receive(:enabled?).and_return true
        allow(Selective).to receive(:call_dummy?).and_return true
        allow(Selective).to receive(:initialize_rspec_hooks)
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
      let(:collector) { double }
      let(:dummy_js_dir) { "spec/dummy/app/javascript" }

      before do
        allow(Selective).to receive(:enabled?).and_return true
        allow(Selective).to receive(:initialize_rspec_hooks)
        allow_any_instance_of(Selective::Config).to receive(:webpacker_app_locations).and_return([dummy_js_dir])

        Selective.initialize_collectors

        Selective.coverage_collectors[described_class] = collector
      end

      it "is called" do
        expect(collector).to receive(:add_covered_globs).with("#{dummy_js_dir}/foo/src/**.{scss,css,js}", "#{dummy_js_dir}/foo/package*.json")
        view.render(inline: '<% javascript_packs_with_chunks_tag "foo" %>')
      end
    end
  end
end
