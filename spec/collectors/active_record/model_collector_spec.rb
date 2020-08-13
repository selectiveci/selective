require "spec_helper"

RSpec.describe Selective::Collectors::ActiveRecord::ModelCollector do
  class DummyCollector < described_class
  end

  describe "#set_hook" do
    it "raises error if inheriting class doesn't implement #set_hook" do
      expect { DummyCollector.new }.to raise_error("Not Implemented")
    end
  end
end
