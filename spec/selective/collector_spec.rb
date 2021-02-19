require "spec_helper"

RSpec.describe Selective::Collector do
  let(:collector) { described_class.new(config) }
  let(:coverage_collector_class_double) { double("Coverage class", new: coverage_collector_instance_double) }
  let(:coverage_collector_instance_double) { double("Coverage instance") }
  let(:config) {
    Selective::Config.new.tap do |config|
      config.api_key = "abc123"
      config.enabled_collector_classes = [coverage_collector_class_double]
    end
  }

  it "initializes" do
    expect(collector.coverage_collectors).to eq(coverage_collector_class_double => coverage_collector_instance_double)
    expect(collector.config).to eq(config)
    expect(collector.map_storage).to be_a(Selective::Storage)
    expect(collector.map).to be_a(Hash)
  end

  describe "#start_recording_code_coverage" do
    subject { collector.start_recording_code_coverage }

    context "when Selective is enabled" do
      before { allow(Selective).to receive(:report_callgraph?).and_return(true) }

      it "calls on_start on coverage_collectors" do
        expect(coverage_collector_instance_double).to receive(:on_start)
        subject
      end
    end

    context "when Selective is not enabled" do
      it "calls on_start on coverage_collectors" do
        expect(coverage_collector_instance_double).not_to receive(:on_start)
        subject
      end
    end
  end

  describe "#write_code_coverage_artifact" do
    subject { collector.write_code_coverage_artifact(example.id) }

    let(:example) { double("example", id: "./foo/bar_spec.rb[1,2]") }
    let(:covered_files) { {"foo/bar.rb" => coverage_data} }
    let(:coverage_data) { double("coverage_data") }

    before do
      allow(coverage_collector_instance_double).to receive(:covered_files).and_return(covered_files)
    end

    context "when Selective is enabled" do
      before { allow(Selective).to receive(:report_callgraph?).and_return(true) }

      it "adds the expected entries to @map" do
        expect { subject }.to change { collector.map }.from({}).to(
          {"./foo/bar_spec.rb[1,2]" => {"foo/bar.rb" => {"RSpec::Mocks::Double" => coverage_data}}}
        )
      end

      it "calls check_dump_threshold" do
        allow(collector).to receive(:check_dump_threshold)
        subject
        expect(collector).to have_received(:check_dump_threshold).once
      end

      context "when Selective.exclude_file? excludes the file" do
        before { allow(Selective).to receive(:exclude_file?).and_return(true) }

        it "adds nothing to @map" do
          expect { subject }.not_to change { collector.map }.from({})
        end
      end
    end

    context "when Selective is not enabled" do
      it "adds nothing to @map" do
        expect { subject }.not_to change { collector.map }.from({})
      end

      it "does not call check_dump_threshold" do
        allow(collector).to receive(:check_dump_threshold)
        subject
        expect(collector).not_to have_received(:check_dump_threshold)
      end
    end
  end

  describe "#finalize" do
    subject { collector.finalize }

    let(:map) { {"./foo/bar_spec.rb[1,2]" => {"foo/bar.rb" => {"RSpec::Mocks::Double" => coverage_data}}} }
    let(:coverage_data) { double("coverage_data") }
    let(:payloads) { [double("payload")] }

    before do
      allow(collector).to receive(:payloads).and_return(payloads)
      allow(collector).to receive(:deliver_payloads)
    end

    context "when Selective is enabled" do
      before { allow(Selective).to receive(:report_callgraph?).and_return(true) }

      context "when the map is not empty" do
        before do
          collector.map = map
          subject
        end

        it "delivers the payloads" do
          expect(collector).to have_received(:deliver_payloads).with(payloads)
        end
      end

      context "when the map is empty/no coverage file exists" do
        before { subject }

        it "does not deliver the payloads" do
          expect(collector).not_to have_received(:deliver_payloads)
        end
      end
    end
  end

  describe "#payloads" do
    subject { collector.payloads }

    let(:payload1) { (1..1000).map { |n| ["foo#{n}_spec", {"bar" => "baz"}] }.flatten }
    let(:payload2) { ["foo1001_spec", {"bar" => "baz"}] }
    let(:payloads) { Hash[*payload1, *payload2] }

    before do
      collector.map_storage.dump(payloads)
      allow(collector).to receive(:`).and_return("foobar")
    end

    it "returns the expected result" do
      result = subject

      expect(result).to be_an(Array)
      expect(result).to all(be_a(Hash))
      expect(result.size).to equal(2)

      result.each do |r|
        expect(r.keys).to eql([:call_graph_data, :git_branch, :git_ref])
        expect(r.fetch(:git_branch)).to eql("foobar")
        expect(r.fetch(:git_ref)).to eql("foobar")
        expect(r.fetch(:call_graph_data)).to be_a(Hash)
      end

      expect(result.first.fetch(:call_graph_data).size).to equal(1000)
      expect(result.first.fetch(:call_graph_data).first).to eql(["foo1_spec", ["bar"]])
      expect(result.first.fetch(:call_graph_data).keys.last).to eql("foo1000_spec")
      expect(result.last.fetch(:call_graph_data).size).to equal(1)
      expect(result.last.fetch(:call_graph_data)).to eql({"foo1001_spec" => ["bar"]})
    end
  end

  describe "#deliver_payloads" do
    subject { collector.deliver_payloads(payloads) }

    let(:payloads) { [{foo: "bar"}.to_json] }

    # This is admittedly a very poor test
    # We will do better when this code gets
    # extracted out of here (very soon)
    it "sends the request" do
      expect(Selective::Api).to receive(:request)
      subject
    end
  end

  describe "#check_dump_threshold" do
    subject { collector.check_dump_threshold }

    before do
      allow(collector.map_storage).to receive(:dump)
    end

    context "when the map.size >= DUMP_THRESHOLD" do
      before do
        collector.map = (0..9).map { |v| {v: {}} }
      end

      it "dumps the map" do
        expect { subject }.to change { collector.map }.to({})
        expect(collector.map_storage).to have_received(:dump)
      end
    end

    context "when the map.size has not met the threshold" do
      it "does nothing" do
        expect { subject }.not_to change { collector.map }
        expect(collector.map_storage).not_to have_received(:dump)
      end
    end
  end

  describe "#git_branch" do
    let(:cmd) { "git rev-parse --abbrev-ref HEAD" }
    let(:branch) { "foo/\nbar/baz" }

    it "git_branch" do
      expect(collector).to receive(:`).with(cmd).and_return(branch)

      result = collector.git_branch

      expect(result).to eql("foo/bar/baz")
    end

    it "git_branch" do
      empty = "" # keep linter from replacing gsub with delete

      result = collector.git_branch

      expect(result).to eql(`git branch --show-current`.gsub(/\n/, empty))
    end
  end

  describe "#git_ref" do
    let(:cmd) { "git rev-parse HEAD" }
    let(:ref) { "\n\n\n563dec1f0db873b6c651fde7cb9f6dd4be37b4a5" }

    it "git_ref" do
      expect(collector).to receive(:`).with(cmd).and_return(ref)

      result = collector.git_ref

      expect(result).to eql("563dec1f0db873b6c651fde7cb9f6dd4be37b4a5")
    end

    it "git_branch" do
      empty = "" # keep linter from replacing gsub with delete

      result = collector.git_ref

      expect(result).to eql(`git log -1 --format="%H"`.gsub(/\n/, empty))
    end
  end
end
