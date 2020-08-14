require "spec_helper"

RSpec.describe Selective do

  describe ".configure" do
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

  describe ".initialize_rspec_hooks" do
    # how do you test a method that does stuff to RSpec config?
    # wondering if this method should be private
    before do
      allow(described_class).to receive(:enabled?).and_return(true)
      described_class
        .collector = Selective::Collector.new(described_class.config)
    end

    after do
      described_class.instance_variable_set(:@config, nil)
      described_class.instance_variable_set(:@collector, nil)
    end

    it "configures RSpec" do
      expect(RSpec).to receive(:configure)

      described_class.initialize_rspec_hooks
    end
  end
end
