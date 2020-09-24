require "spec_helper"

RSpec.describe Selective::Collectors::ActiveRecord::ModelCollector do
  class DummyCollector < described_class
  end

  class DummyCollector2 < described_class
    def set_hook
    end

    def data
      [1, 2, 5]
    end
  end

  class DummyCollector3 < described_class
    def set_hook
    end
  end

  class BadModel
  end

  describe "#initialize" do
    it "raises error if inheriting class doesn't implement #set_hook" do
      expect { DummyCollector.new }.to raise_error("Not Implemented")
    end
  end

  describe "#on_start" do
    let(:object) { DummyCollector2.new }
    it "starts" do
      expect(object.on_start).to eql Set.new
      expect(object.instance_variable_get("@covered_model_collection")).to eql Set.new
    end
  end

  describe "#add_covered_models" do
    let(:object) { DummyCollector2.new }
    it "adds" do
      expect(object.add_covered_models(ADummy, BDummy)).to eql Set.new([ADummy, BDummy])
      expect(object.instance_variable_get("@covered_model_collection")).to eql Set.new([ADummy, BDummy])
    end

    it "rejects if not ActiveRecord classes" do
      expect{ object.add_covered_models(ADummy.new) }.to raise_error StandardError
    end
  end

  describe "#covered_files" do
    let(:object) { DummyCollector2.new }
    it "adds" do
      object.on_start
      object.add_covered_models(ADummy, BadModel, B1Dummy)

      expect(object.covered_files).
        to eql({"#{Dir.pwd}/spec/dummy/app/models/a_dummy.rb" => [1, 2, 5],
        "#{Dir.pwd}/spec/dummy/app/models/b1_dummy.rb" => [1, 2, 5]})
    end

    it "adds" do
      object = DummyCollector3.new
      object.add_covered_models(ADummy, BadModel, BDummy)

      expect(object.covered_files).
        to eql({"#{Dir.pwd}/spec/dummy/app/models/a_dummy.rb" => nil,
        "#{Dir.pwd}/spec/dummy/app/models/b_dummy.rb" => nil})

      expect(object.covered_files).to eql({})

      expect(object.instance_variable_get("@covered_model_collection")).to eql Set.new
    end
  end
end
