# frozen_string_literal: true

require "spec_helper"
require "selective"

RSpec.describe Selective::Config do
  let(:object) { described_class.new }

  describe "#initialize" do
    it "initializes" do
      expect(object.enabled_collector_classes)
        .to eql(described_class::DEFAULT_COLLECTOR_CLASSES)
      expect(object.webpacker_app_locations.first).to eql(described_class::DEFAULT_WEBPACKER_LOCATION)
      expect(object.webpacker_app_locations.size).to equal(1)
      expect(object.file_exclusion_check).to be_an_instance_of(Proc)
      expect(object.file_exclusion_check.call).to be false
      expect(object.report_callgraph_check).to be_a(Proc)
      expect(object.report_callgraph_check.call).to be false
      expect(object.sprockets_asset_collector_class)
        .to equal(Selective::Collectors::SprocketsAssetCollector)
      expect(object.coverage_path).to be_an_instance_of(Pathname)
      expect(object.coverage_path.to_s).to eql("/tmp/coverage-map.yml")
      expect(object.api_key).to eql(ENV.fetch("SELECTIVE_API_KEY", nil))
      expect(object.backend_host).to equal("https://selective-ci.herokuapp.com")
    end

    context "with host" do
      before do
        ENV["SELECTIVE_BACKEND_HOST"] = "xyz"
      end

      after do
        ENV.delete("SELECTIVE_BACKEND_HOST")
      end

      it "initializes" do
        expect(object.backend_host).to eql("xyz")
      end
    end

    context "with api key" do
      before do
        ENV["SELECTIVE_API_KEY"] = "the_api_key"
      end

      after do
        ENV.delete("SELECTIVE_API_KEY")
      end

      it "initializes" do
        expect(object.api_key).to eql("the_api_key")
      end
    end
  end
end
