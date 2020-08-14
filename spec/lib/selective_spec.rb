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
    before do
     # described_class.instance_variable_set(:@config, nil)
    end

    after do
      described_class.instance_variable_set(:@config, nil)
    end

    it "sets config ivar" do
      result = described_class.configure {}

      expect(result).to be_nil
      expect(described_class.instance_variable_get(:@config))
        .to be_an_instance_of(Selective::Config)
    end

    it "yields" do
      result = described_class.configure { |_| :foo }

      expect(result).to equal(:foo)
      expect(described_class.instance_variable_get(:@config))
        .to be_an_instance_of(Selective::Config)
    end
  end

  describe ".config" do
    before do
      #described_class.instance_variable_set(:@config, nil)
    end

    after do
      described_class.instance_variable_set(:@config, nil)
    end

    it "sets config ivar" do
      result = described_class.config

      expect(result).to be_an_instance_of(Selective::Config)
      expect(described_class.instance_variable_get(:@config))
        .to eql(result)
    end
  end

  describe ".initialize_collectors" do
    context "when enabled" do
      before do
        allow(described_class).to receive(:enabled?).and_return(true)
        described_class.config
      end

      after do
        described_class.instance_variable_set(:@config, nil)
        described_class.instance_variable_set(:@collector, nil)
      end

      it "sets collector ivar" do
        allow(described_class).to receive(:initialize_rspec_hooks)

        described_class.initialize_collectors

        expect(described_class.collector)
          .to be_an_instance_of(Selective::Collector)
      end

      it "initializes rspec hooks" do
        expect(described_class).to receive(:initialize_rspec_hooks)

        described_class.initialize_collectors
      end
    end

    context "when not enabled" do
      before do
        allow(described_class).to receive(:enabled?).and_return(false)
        described_class.config
      end

      after do
        described_class.instance_variable_set(:@config, nil)
      end

      it "does not set collector ivar" do
        described_class.initialize_collectors

        expect(described_class.collector).to be_nil
      end

      it "does not initialize rspec hooks" do
        expect(described_class).not_to receive(:initialize_rspec_hooks)

        described_class.initialize_collectors
      end
    end
  end
end
