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
    subject { described_class.initialize_rspec_reporting_hooks }

    let(:rspec_config) { RSpec::Core::Configuration.new }
    let(:collector) { double(:collector, start_recording_code_coverage: nil, write_code_coverage_artifact: nil, finalize: nil) }
    let(:example) { double(:example, id: nil, run: nil) }

    before do
      allow(RSpec).to receive(:configure).and_yield(rspec_config)
      allow(Selective).to receive(:collector).and_return(collector)
    end

    context "around_example hooks" do
      it "sets one hook" do
        expect { subject }.to change { rspec_config_hooks_for(:around_example).length }.by(1)
      end

      context "when calling the hook" do
        before do
          subject
          hooks = rspec_config_hooks_for(:around_example)
          hooks.first.block.call(example)
        end

        it "starts recording code coverage" do
          expect(collector).to have_received(:start_recording_code_coverage).once
        end

        it "writes the code coverage artifact" do
          expect(collector).to have_received(:write_code_coverage_artifact).once
        end

        it "runs the example" do
          expect(example).to have_received(:run).once
        end
      end
    end

    context "after_suite hooks" do
      it "sets one hook" do
        expect { subject }.to change { rspec_config_hooks_for(:after_suite).length }.by(1)
      end

      context "when calling the hook" do
        before do
          subject
          hooks = rspec_config_hooks_for(:after_suite)
          hooks.first.block.call(example)
        end

        it "calls finalize on the collector" do
          expect(collector).to have_received(:finalize).once
        end
      end
    end
  end

  describe ".initialize_test_selection" do
    subject { described_class.initialize_test_selection }

    let(:rspec_config) { RSpec::Core::Configuration.new }
    let(:tests_from_diff) { ["./spec/foo/bar_spec.rb"] }
    let(:skipped_tests) { [] }

    before do
      allow(RSpec).to receive(:configure).and_yield(rspec_config)
      allow(Selective::Selector).to receive(:tests_from_diff).and_return(tests_from_diff)
      allow(Selective).to receive(:selected_tests=)
      allow(Selective).to receive(:selected_tests).and_return(tests_from_diff)
      allow(Selective).to receive(:skipped_tests).and_return(skipped_tests)
    end

    context "before_suite hooks" do
      it "sets one hook" do
        expect { subject }.to change { rspec_config_hooks_for(:before_suite).length }.by(1)
      end

      context "when calling the hook" do
        before do
          subject
          hooks = rspec_config_hooks_for(:before_suite)
          hooks.first.block.call(double("example", run: nil))
        end

        it "sets Selective.selected_tests=" do
          expect(Selective).to have_received(:selected_tests=).with(tests_from_diff)
        end
      end
    end

    context "around_example hooks" do
      let(:example) { double(:example, run: nil, id: nil, file_path: nil) }

      it "sets one hook" do
        expect { subject }.to change { rspec_config_hooks_for(:around_example).length }.by(1)
      end

      context "when calling the hook" do
        before do
          subject
          hooks = rspec_config_hooks_for(:around_example)
          hooks.first.block.call(example)
        end

        context "when Selective.selected_tests is empty" do
          let(:tests_from_diff) { [] }

          it "runs the example" do
            expect(example).to have_received(:run).once
          end
        end

        context "when Selective.selected_tests includes the example id" do
          let(:tests_from_diff) { ["./spec/foo/bar_spec.rb[1:1]"] }
          let(:example) { double(:example, run: nil, id: tests_from_diff.first, file_path: nil) }

          it "runs the example" do
            expect(example).to have_received(:run).once
          end
        end

        context "when Selective.selected_tests includes the file path" do
          let(:example) { double(:example, run: nil, id: nil, file_path: tests_from_diff.first) }

          it "runs the example" do
            expect(example).to have_received(:run).once
          end
        end

        context "when Selective.selected_tests does not match the example" do
          let(:example_id) { "foobar" }
          let(:example) { double(:example, run: nil, id: example_id, file_path: nil) }

          it "does not run the example" do
            expect(example).not_to have_received(:run)
          end

          it "adds the example to Selective.skipped_tests" do
            expect(skipped_tests).to include(example_id)
          end
        end
      end
    end

    context "after_suite hooks" do
      it "sets one hook" do
        expect { subject }.to change { rspec_config_hooks_for(:after_suite).length }.by(1)
      end

      context "when calling the hook" do
        let(:example_id) { "./spec/bar/baz_spec.rb" }
        let(:example) { double(:example, run: nil, id: example_id, file_path: nil) }
        let(:examples) { [example] }
        let(:pending_examples) { [example] }

        let(:reporter) { double("reporter", examples: examples, pending_examples: pending_examples) }
        let(:suite) { double("suite", reporter: reporter) }

        before do
          subject
        end

        context "when skipped_tests is empty" do
          it "does not delete examples" do
            hooks = rspec_config_hooks_for(:after_suite)
            expect { hooks.first.block.call(suite) }.not_to change { examples.length }
          end

          it "does not delete pending examples" do
            hooks = rspec_config_hooks_for(:after_suite)
            expect { hooks.first.block.call(suite) }.not_to change { pending_examples.length }
          end
        end

        context "when skipped_tests matches an example" do
          let(:skipped_tests) { [example_id] }

          it "removes the example from examples" do
            hooks = rspec_config_hooks_for(:after_suite)
            expect(examples).to include(example)
            hooks.first.block.call(suite)
            expect(examples).not_to include(example)
          end

          it "removes the example from pending_examples" do
            hooks = rspec_config_hooks_for(:after_suite)
            expect(pending_examples).to include(example)
            hooks.first.block.call(suite)
            expect(pending_examples).not_to include(example)
          end
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

  describe ".run_example?" do
    let(:file_path) { "./spec/foo/bar_spec.rb" }
    let(:example) { double(:example, run: nil, id: "foobar", file_path: file_path) }

    it "returns true if no selected tests" do
      allow(described_class).to receive(:selected_tests).and_return([])

      result = described_class.run_example?(example)

      expect(result).to be true
    end

    it "returns true if example id was selected" do
      allow(described_class).to receive(:selected_tests).and_return(["foobar"])

      result = described_class.run_example?(example)

      expect(result).to be true
    end

    it "returns true if example filepath was selected" do
      allow(described_class).to receive(:selected_tests).and_return([file_path])

      result = described_class.run_example?(example)

      expect(result).to be true
    end

    it "returns false if example id/path were not selected" do
      allow(described_class).to receive(:selected_tests).and_return(["baz"])

      result = described_class.run_example?(example)

      expect(result).to be false
    end
  end

  describe ".skipped_test?" do
    let(:example) { double(:example, run: nil, id: "foobar", file_path: nil) }

    it "returns true if test was skipped" do
      allow(described_class).to receive(:skipped_tests).and_return(["foobar"])

      result = described_class.skipped_test?(example)

      expect(result).to be true
    end

    it "returns false if test was not skipped" do
      allow(described_class).to receive(:skipped_tests).and_return(["baz"])

      result = described_class.skipped_test?(example)

      expect(result).to be false
    end
  end
end
