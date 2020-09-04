require "spec_helper"
require "method_source"

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
    before do
      allow(described_class).to receive(:enabled?).and_return(true)
      described_class
        .collector = Selective::Collector.new(described_class.config)
    end

    after do
      described_class.instance_variable_set(:@config, nil)
      described_class.instance_variable_set(:@collector, nil)
    end

    let(:configure) { double }

    it "configures RSpec" do
      expect(RSpec).to receive(:configure).and_yield(configure)
      allow(Selective::Api).to receive(:request)
      expect(configure).to receive(:before).with(:example).once.and_yield
      expect(configure).to receive(:after).with(:example).once.and_yield(double(id: 1))
      expect(configure).to receive(:after).with(:suite).once.and_yield

      described_class.initialize_rspec_hooks
    end

    context "with hooks" do
      let(:expected_hooks) do
        {
          [:@before_example_hooks, :@items_and_filters] => "{ Selective.collector.start_recording_code_coverage }",
          [:@after_example_hooks, :@items_and_filters] => "{ |example| Selective.collector.write_code_coverage_artifact(example) }",
          [:@owner, :@after_suite_hooks] => "{ Selective.collector.finalize }"
        }
      end
      let(:rspec_config) { RSpec::Core::Configuration.new }

      it "has expected hooks" do
        allow(RSpec).to receive(:configure).and_yield(rspec_config)

        described_class.initialize_rspec_hooks

        expected_hooks.each do |hooks, code|
          hook_ptr = rspec_config.hooks

          hooks.each do |hook|
            hook_ptr = hook_ptr.instance_variable_get(hook)
          end

          source = hook_ptr.flatten
            .first
            .block
            .source

          expect(source).to include(code)
        end
      end
    end
  end

  describe ".start_coverage" do
    context "when enabled" do
      let(:collector) { double }
      let(:collectors) do
        {Selective::Collectors::RubyCoverageCollector => collector}
      end

      it "starts each collector" do
        allow(described_class).to receive(:enabled?).and_return(true)
        expect(described_class)
          .to receive(:coverage_collectors).and_return(collectors)
        expect(collector).to receive(:on_start)

        described_class.start_coverage
      end
    end

    context "when not enabled" do
      it "does nothing" do
        allow(described_class).to receive(:enabled?).and_return(false)
        expect(described_class).not_to receive(:coverage_collectors)

        result = described_class.start_coverage

        expect(result).to be nil
      end
    end
  end

  describe ".enabled?" do
    context "when env var is not nil" do
      let(:env_was) { ENV["TEST_COVERAGE_ENABLED"] }

      before do
        env_was
        ENV["TEST_COVERAGE_ENABLED"] = "t"
      end

      after { ENV["TEST_COVERAGE_ENABLED"] = env_was }

      it "returns true" do
        result = described_class.enabled?

        expect(result).to be true
      end
    end

    context "when env var is nil" do
      let(:env_was) { ENV["TEST_COVERAGE_ENABLED"] }

      before do
        env_was
        ENV["TEST_COVERAGE_ENABLED"] = nil
      end

      after { ENV["TEST_COVERAGE_ENABLED"] = env_was }

      it "returns false" do
        result = described_class.enabled?

        expect(result).to be false
      end
    end
  end

  describe ".exclude_file?" do
    it "returns false" do
      result = described_class.exclude_file?(Pathname.new("foo"))

      expect(result).to be false
    end
  end
end
