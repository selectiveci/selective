require "spec_helper"

RSpec.describe Selective::Collectors::ActiveRecord::ModelFileFinder do
  let(:finder) { described_class.new }

  class IrregularlyPlacedModel < ::ActiveRecord::Base
  end

  describe "#file_path" do
    it "finds the path too rails models" do
      expect(finder.file_path(ADummy)).to eq(Rails.root.join("app", "models", "a_dummy.rb").to_s)
      expect(finder.file_path(BDummy)).to eq(Rails.root.join("app", "models", "b_dummy.rb").to_s)

      expect(finder.file_path(B1Dummy)).to eq(Rails.root.join("app", "models", "b1_dummy.rb").to_s)
    end

    it "finds the path to namespaced modules" do
      expect(finder.file_path(SomeNamespace::NamespacedDummy)).to eq(Rails.root.join("app", "models", "some_namespace", "namespaced_dummy.rb").to_s)
    end

    it "returns nil when the file is not found" do
      expect(finder.file_path(IrregularlyPlacedModel)).to be_nil
    end

    it "finds the path to rails engine models" do
      expect(finder.file_path(DummyEngine::EngineDummy)).to eq(Rails.root.join("engines", "dummy_engine", "app", "models", "dummy_engine", "engine_dummy.rb").to_s)
    end
  end
end
