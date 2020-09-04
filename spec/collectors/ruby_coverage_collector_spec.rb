# frozen_string_literal: true

require "spec_helper"
require "selective"

RSpec.describe Selective::Collectors::RubyCoverageCollector do
  subject(:collector) { described_class.new }

  describe "attr_reader :root_path" do
    it { is_expected.to respond_to(:root_path) }
    it { is_expected.not_to respond_to(:root_path=) }
  end

  describe "#initialize" do
    context "when Coverage is running" do
      before do
        allow(Coverage).to receive(:running?).and_return(true)
      end

      it "does not start Coverage" do
        expect(Coverage).not_to receive(:start)
        collector
      end
    end

    context "when Coverage is not running" do
      before do
        allow(Coverage).to receive(:running?).and_return(false)
      end

      it "starts Coverage" do
        expect(Coverage).to receive(:start)
        collector
      end
    end

    context "when root_path is passed" do
      subject(:collector) { described_class.new(root_path) }

      let(:root_path) { "/test" }

      it "sets @root_path to passed argument" do
        expect(collector.instance_variable_get(:@root_path)).to eq(root_path)
      end
    end

    context "when no root_path is passed" do
      it "sets @root_path to present directory" do
        expect(collector.instance_variable_get(:@root_path)).to eq(Dir.pwd)
      end
    end
  end

  let(:before_peek_result) do
    {
      "#{Dir.pwd}/file1.rb" => [1, nil, 1, nil],
      "#{Dir.pwd}/file2.rb" => [nil, nil, 1, 1],
      "#{Dir.pwd}/file3.rb" => [1, nil, 1, 1]
    }
  end

  let(:after_peek_result) do
    {
      "#{Dir.pwd}/file1.rb" => [1, 1, 1, nil],
      "#{Dir.pwd}/file2.rb" => [nil, nil, 1, 1],
      "#{Dir.pwd}/file3.rb" => [1, 1, 1, 1],
      "#{Dir.pwd}/file4.rb" => [nil, 1, 1, 1],
      "#{Dir.pwd}/spec/file5.rb" => [nil, nil, 1, 1],
      "/path/to/file6.rb" => [nil, 1, nil, nil]
    }
  end

  describe "#on_start" do
    before do
      allow(Coverage).to receive(:peek_result).and_return(before_peek_result)
    end

    it "assigns Coverage.peek_result to @before" do
      expect {
        collector.on_start
      }.to change {
        collector.instance_variable_get(:@before)
      }.from(nil).to(before_peek_result)
    end
  end

  describe "#covered_files" do
    subject(:covered_files) { collector.covered_files }

    before do
      collector.instance_variable_set(:@before, before_peek_result)
      allow(Coverage).to receive(:peek_result).and_return(after_peek_result)
      allow(Selective).to receive(:exclude_file?) { |file|
        file == "#{Dir.pwd}/file1.rb"
      }
    end

    it "excludes files marked for exclusion in Selective config" do
      expect(covered_files.keys).not_to include("#{Dir.pwd}/file1.rb")
    end

    it "rejects after results that are identical to before" do
      expect(covered_files.keys).not_to include("#{Dir.pwd}/file2.rb")
    end

    it "includes after results that have changed from before" do
      expect(covered_files.keys).to include("#{Dir.pwd}/file3.rb")
    end

    it "includes new files" do
      expect(covered_files.keys).to include("#{Dir.pwd}/file4.rb")
    end

    it "excludes paths containing /spec" do
      expect(covered_files.keys).not_to include("#{Dir.pwd}/spec/file5.rb")
    end

    it "excludes paths not beginning with root_path" do
      expect(covered_files.keys).not_to include("/path/to/file6.rb")
    end

    it "sets all values to true" do
      expect(covered_files.values).to all(be true)
    end
  end
end
