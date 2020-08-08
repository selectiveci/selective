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
      before { allow(Selective).to receive(:enabled?).and_return(true) }

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
    subject { collector.write_code_coverage_artifact(example) }

    let(:example) { double("example", id: "./foo/bar_spec.rb[1,2]") }
    let(:covered_files) { {"foo/bar.rb" => coverage_data} }
    let(:coverage_data) { double("coverage_data") }

    before do
      allow(coverage_collector_instance_double).to receive(:covered_files).and_return(covered_files)
    end

    context "when Selective is enabled" do
      before { allow(Selective).to receive(:enabled?).and_return(true) }

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

  context "#finalize" do
    subject { collector.finalize }

    let(:map) { {"./foo/bar_spec.rb[1,2]" => {"foo/bar.rb" => {"RSpec::Mocks::Double" => coverage_data}}} }
    let(:coverage_data) { double("coverage_data") }
    let(:payload) { double("payload") }

    before do
      allow(collector).to receive(:payload).and_return(payload)
      allow(collector).to receive(:deliver_payload)
    end

    context "when Selective is enabled" do
      before { allow(Selective).to receive(:enabled?).and_return(true) }

      context "when the map is not empty" do
        before do
          collector.map = map
          subject
        end

        it "delivers the payload" do
          expect(collector).to have_received(:deliver_payload).with(payload)
        end
      end

      context "when the map is empty/no coverage file exists" do
        before { subject }

        it "does not deliver the payload" do
          expect(collector).not_to have_received(:deliver_payload)
        end
      end
    end
  end

  context "#payload" do
    subject { collector.payload }

    before do
      collector.map_storage.dump({foo: {"bar" => "baz"}})
      allow(collector).to receive(:`).and_return("foobar")
    end

    it "returns the expected result" do
      expect(subject).to eq({call_graph_data: {foo: ["bar"]}, git_branch: "foobar", git_ref: "foobar"})
    end
  end

  context "#deliver_payload" do
    subject { collector.deliver_payload(payload) }

    let(:payload) { {foo: "bar"}.to_json }

    # This is admittedly a very poor test
    # We will do better when this code gets
    # extracted out of here (very soon)
    it "sends the request" do
      expect_any_instance_of(Net::HTTP).to receive(:request)
      subject
    end
  end

  context '#check_dump_threshold' do
    subject { collector.check_dump_threshold }

    before do
      allow(collector.map_storage).to receive(:dump)
    end

    context 'when the map.size >= DUMP_THRESHOLD' do
      before do
        collector.map = (0..9).map {|v| {v: {}} }
      end

      it 'dumps the map' do
        expect { subject }.to change { collector.map }.to({})
        expect(collector.map_storage).to have_received(:dump)
      end
    end

    context 'when the map.size has not met the threshold' do
      it 'does nothing' do
        expect { subject }.not_to change { collector.map }
        expect(collector.map_storage).not_to have_received(:dump)
      end
    end
  end
end
