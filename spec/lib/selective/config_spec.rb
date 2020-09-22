# frozen_string_literal: true

require "spec_helper"
require "selective"

RSpec.describe Selective::Config do
  let(:object) { described_class.new }

  describe "#initialize" do
    it "initializes" do
      expect(object.enabled_collector_classes)
        .to eql(described_class::DEFAULT_COLLECTOR_CLASSES)
      expect(object.webpacker_app_locations).not_to be_empty
      expect(object.file_exclusion_check).to be_a(Proc)
      expect(object.file_exclusion_check.call).to be false
      expect(object.report_callgraph_check).to be_a(Proc)
      expect(object.report_callgraph_check.call).to be false
      expect(object.sprockets_asset_collector_class)
        .to eql(Selective::Collectors::SprocketsAssetCollector)
      expect(object.coverage_path).to be_a(Pathname)
      expect(object.coverage_path.to_s).to match(%r{/tmp/.*\.yml})
      expect(object.api_key).to eql(ENV.fetch("SELECTIVE_API_KEY", nil))
    end
  end
end
