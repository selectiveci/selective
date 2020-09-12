require "spec_helper"
require "method_source"

RSpec.describe Selective do
  describe ".start" do
    after do
      described_class.instance_variable_set(:@config, nil)
    end

    it "sets config ivar" do
      result = described_class.start {}

      expect(result).to be_nil
      expect(described_class.instance_variable_get(:@config))
        .to be_an_instance_of(Selective::Config)
    end

    it "yields" do
      described_class.start { |config| config.api_key = :abc123 }

      expect(Selective.config.api_key).to equal(:abc123)
      expect(described_class.instance_variable_get(:@config))
        .to be_an_instance_of(Selective::Config)
    end

    context "when report_callgraph? is true" do
      before { allow(described_class).to receive(:report_callgraph?).and_return(true) }

      it "calls initialize_collectors" do
        allow(described_class).to receive(:initialize_collectors)
        described_class.start
        expect(described_class).to have_received(:initialize_collectors)
      end
    end

    context "when report_callgraph? is false" do
      before { allow(described_class).to receive(:report_callgraph?).and_return(false) }

      it "does not call initialize_collectors" do
        allow(described_class).to receive(:initialize_collectors)
        described_class.start
        expect(described_class).not_to have_received(:initialize_collectors)
      end
    end

    context "when select_tests? is true" do
      before { allow(described_class).to receive(:select_tests?).and_return(true) }

      it "calls initialize_test_selection" do
        allow(described_class).to receive(:initialize_test_selection)
        described_class.start
        expect(described_class).to have_received(:initialize_test_selection)
      end
    end

    context "when select_tests? is false" do
      before { allow(described_class).to receive(:select_tests?).and_return(false) }

      it "does not call initialize_test_selection" do
        allow(described_class).to receive(:initialize_test_selection)
        described_class.start
        expect(described_class).not_to have_received(:initialize_test_selection)
      end
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
        allow(described_class).to receive(:report_callgraph?).and_return(true)
        described_class.config
      end

      after do
        described_class.instance_variable_set(:@config, nil)
        described_class.instance_variable_set(:@collector, nil)
      end

      it "sets collector ivar" do
        allow(described_class).to receive(:initialize_rspec_reporting_hooks)

        described_class.initialize_collectors

        expect(described_class.collector)
          .to be_an_instance_of(Selective::Collector)
      end

      it "initializes rspec hooks" do
        expect(described_class).to receive(:initialize_rspec_reporting_hooks)

        described_class.initialize_collectors
      end
    end
  end

  describe ".initialize_rspec_reporting_hooks" do
    let(:rspec_config) { RSpec::Core::Configuration.new }

    context "with hooks" do
      let(:expected_hooks) do
        {
          %i[@around_example_hooks @items_and_filters] => 1,
          %i[@owner @after_suite_hooks] => 1
        }
      end

      it "has expected hooks" do
        allow(RSpec).to receive(:configure).and_yield(rspec_config)

        expect { described_class.initialize_rspec_reporting_hooks }.to change {
          expected_hooks.map do |hooks, codes|
            hook_ptr = rspec_config.hooks

            hooks.each do |hook|
              hook_ptr = hook_ptr.instance_variable_get(hook)
            end

            hook_ptr.flatten.count do |item|
              next unless item.respond_to?(:block)
              item.block.source_location.first.include?("selective/lib")
            end
          end
        }.from([0, 0]).to(expected_hooks.values)
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
        allow(described_class).to receive(:report_callgraph?).and_return(true)
        expect(described_class)
          .to receive(:coverage_collectors).and_return(collectors)
        expect(collector).to receive(:on_start)

        described_class.start_coverage
      end
    end

    context "when not enabled" do
      it "does nothing" do
        allow(described_class).to receive(:report_callgraph?).and_return(false)
        expect(described_class).not_to receive(:coverage_collectors)

        result = described_class.start_coverage

        expect(result).to be nil
      end
    end
  end

  describe ".report_callgraph?" do
    context "when env var is not nil" do
      let(:env_was) { ENV["SELECTIVE_REPORT_CALLGRAPH"] }

      before do
        env_was
        ENV["SELECTIVE_REPORT_CALLGRAPH"] = "t"
      end

      after { ENV["SELECTIVE_REPORT_CALLGRAPH"] = env_was }

      it "returns true" do
        result = described_class.report_callgraph?

        expect(result).to be true
      end
    end

    context "when env var is nil" do
      let(:env_was) { ENV["SELECTIVE_REPORT_CALLGRAPH"] }

      before do
        env_was
        ENV["SELECTIVE_REPORT_CALLGRAPH"] = nil
      end

      after { ENV["SELECTIVE_REPORT_CALLGRAPH"] = env_was }

      it "returns false" do
        result = described_class.report_callgraph?

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
