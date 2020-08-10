require "spec_helper"

RSpec.describe Selective do
  describe Selective::Config do
    let(:object) { described_class.new }

    describe "#initialize" do
      it "initializes" do
        expect(object.enabled_collector_classes)
          .to match_array([
            Selective::Collectors::RubyCoverageCollector,
            Selective::Collectors::ActiveRecord::AssociationCollector,
            Selective::Collectors::ActiveRecord::AttributeWriterCollector,
            Selective::Collectors::ActiveRecord::AttributeReaderCollector,
            Selective::Collectors::ActionView::RenderedTemplateCollector,
            Selective::Collectors::ActionView::AssetTagCollector,
            Selective::Collectors::Webpacker::WebpackerAppCollector
          ])
        expect(object.webpacker_app_locations).not_to be_empty
        expect(object.file_exclusion_check).to be_a(Proc)
        expect(object.file_exclusion_check.call).to be false
        expect(object.enable_check).to be_a(Proc)
        expect(object.enable_check.call).to be false
        expect(object.sprockets_asset_collector_class)
          .to eql(Selective::Collectors::SprocketsAssetCollector)
        expect(object.coverage_path).to be_a(Pathname)
        expect(object.coverage_path.to_s).to eql("/tmp/coverage-map.yml")
        expect(object.api_key).to be_nil
      end
    end
  end

  describe ".configure" do
    xit "sets config ivar" do

    end
  end
end
