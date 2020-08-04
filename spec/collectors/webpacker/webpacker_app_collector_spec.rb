require "spec_helper"

RSpec.describe Selective::Collectors::Webpacker::WebpackerAppCollector do
  class DummyView < ActionView::Base
  end

  describe "#add_covered_globs" do
    let(:dummy_js_dir) { 'spec/dummy/app/javascript' }

    before do
      @mock_collector = double
      allow(Selective).to receive(:coverage_collectors).and_return({
        Selective::Collectors::Webpacker::WebpackerAppCollector => @mock_collector
      })
      allow(@mock_collector).to receive(:on_start)

      Selective.start_coverage
      Selective.configure do |config|
        config.webpacker_app_locations = [dummy_js_dir]
      end
    end

    context 'when selective is not enabled'do
      let(:view) { DummyView.new(::ActionView::LookupContext.new([]), {}) }

      it 'is not called' do
        expect(@mock_collector).not_to receive(:add_covered_globs)
        view.extend(::Webpacker::Helper)
        view.render(inline: '<% javascript_packs_with_chunks_tag "foo" %>')
      end
    end

    context 'when selective is enabled' do
      let(:view) { DummyView.new(::ActionView::LookupContext.new([]), {}) }

      it 'is called' do
        expect(@mock_collector).to receive(:add_covered_globs).with("#{dummy_js_dir}/foo/src/**.{scss,css,js}", "#{dummy_js_dir}/foo/package*.json")
        view.extend(Selective::Collectors::Webpacker::Helpers)
        view.render(inline: '<% javascript_packs_with_chunks_tag "foo" %>')
      end
    end
  end
end
