# frozen_string_literal: true

require "spec_helper"
require "selective"

RSpec.describe Selective::Storage do
  subject { described_class.new(path) }
  let(:path) { Pathname.new("spec/fixtures/storage.yml") }

  describe "NoFilesFoundError" do
    subject { Selective::Storage::NoFilesFoundError }
    it { is_expected.to be < StandardError }
  end

  describe "attr_reader :path" do
    it { is_expected.to respond_to(:path) }
    it { is_expected.not_to respond_to(:path=) }
  end

  describe "#initialize" do
    it "sets the @path variable" do
      expect(subject.instance_variable_get(:@path)).to eq(path)
    end
  end

  describe "class methods" do
    subject { described_class }

    describe ".load" do
      subject { super().load(path) }

      context "when file does not exist" do
        let(:path) { Pathname.new("does-not-exist.yml") }

        it "raises a NoFilesFoundError" do
          expect { subject }.to raise_error(Selective::Storage::NoFilesFoundError, "No file exists #{path}")
        end
      end

      context "when file exists and is valid YAML" do
        it "returns expected hash" do
          expect(subject).to eq(
            {
              "bax" => "quux",
              "foo" => {
                "bar" => "baz"
            }
           }
         )
        end
      end

      context "when file exists and is invalid YAML" do
        let(:path) { Pathname.new("spec/fixtures/bad_storage.yml") }

        it "returns expected hash" do
          expect { subject }.to raise_error(Psych::DisallowedClass, "Tried to load unspecified class: Date")
        end
      end
    end
  end

  describe "#clear!" do
    let(:path) { Pathname.new(Tempfile.new("empter/clear-test")) }

    context "when the file does not exist" do
      let(:path) { 
        a = Pathname.new(Tempfile.new("empter/clear-test"))
        a.delete
        a
       }

      it "does not raise an error" do
        expect(subject.path.exist?).to be false
        expect { subject.clear! }.not_to raise_error
      end
    end

    context "when the file exists" do
      it "deletes the file" do
        expect { subject.clear! }.to change { subject.path.exist? }.from(true).to(false)
      end
    end
  end

  describe "#dump" do
    let(:path) { 
      FileUtils.mkdir_p("/tmp/path#{Process.pid}")
      Pathname.new(Tempfile.open("empercdump-test.yml", "/tmp/path#{Process.pid}")) }
    let(:data) { {"frog" => "cat"} }

    context "when subdirectories do not exist" do
      before { FileUtils.rm_r(path.dirname) if path.dirname.exist? }

      it "creates them" do
        expect { subject.dump(data) }.to change { path.dirname.exist? }.from(false).to(true)
      end
    end

    context "when subdirectories and file already exist" do
      before do
        path.dirname.mkpath
        File.write(path, {"dog" => "bird"}.to_yaml)
      end

      it "appends data to file as YAML" do
        expect {
          subject.dump(data)
        }.to change {
          described_class.load(path)
        }.from(
          {"dog" => "bird"}
        ).to(
          {
            "frog" => "cat",
            "dog" => "bird"
          }
        )
      end
    end
  end
end
