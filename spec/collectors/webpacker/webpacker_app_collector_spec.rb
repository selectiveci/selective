require "spec_helper"

RSpec.describe Selective::Collectors::Webpacker::WebpackerAppCollector do
  class DummyView < ActionView::Base
  end

  describe "#add_covered_globs" do
    let(:dummy_js_dir) { 'spec/dummy/app/javascript' }

    context 'when selective is disabled' do
      let(:view) { DummyView.new(::ActionView::LookupContext.new([]), {}) }
      let(:collector) { double }

      before do
        allow(Selective).to receive(:coverage_collectors).and_return({
          described_class => collector
        })
      end

      it 'is not called' do
        expect(collector).not_to receive(:add_covered_globs)
        view.extend(::Webpacker::Helper)
        view.render(inline: '<% javascript_packs_with_chunks_tag "foo" %>')
      end
    end

    context 'when selective is enabled', :full_setup do
      let(:view) { DummyView.new(::ActionView::LookupContext.new([]), {}) }
      let(:collector) { double }
      
      before do
        allow(Selective).to receive(:enabled?).and_return true
        allow(Selective).to receive(:initialize_rspec_hooks)
  
        Selective.initialize_collectors
        Selective.configure do |config|
          config.webpacker_app_locations = [dummy_js_dir]
        end
  
        Selective.coverage_collectors[described_class] = collector
      end

      it 'is called' do
        expect(collector).to receive(:add_covered_globs).with("#{dummy_js_dir}/foo/src/**.{scss,css,js}", "#{dummy_js_dir}/foo/package*.json")
        view.extend(Selective::Collectors::Webpacker::Helpers)
        view.render(inline: '<% javascript_packs_with_chunks_tag "foo" %>')
      end
    end
  end
end
