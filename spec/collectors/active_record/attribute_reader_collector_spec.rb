require "spec_helper"

RSpec.describe Selective::Collectors::ActiveRecord::AttributeReaderCollector do
  before do
    allow(Selective).to receive(:report_callgraph?).and_return true
    allow(Selective).to receive(:initialize_rspec_reporting_hooks)
    Selective.initialize_collectors
    Selective.start_coverage
  end

  describe "#set_hook" do
    it "includes helper in ActiveRecord::Base" do
      expect(::ActiveRecord::Base.included_modules).to include(Selective::Collectors::ActiveRecord::AttributeReaderHelper)
    end
  end

  describe "#data" do
    it "annotates #covered_files hash properly" do
      1.times { a = ADummy.new; a.attr1; a.attr1 }
      1.times { b = BDummy.new; b.attr1; b.attr1 }

      result = Selective.coverage_collectors[described_class].covered_files

      expect(result.keys.size).to equal(2)
      expect(result.keys.first).to match(/spec\/dummy\/app\/models\/a_dummy\.rb/)
      expect(result.keys.last).to match(/spec\/dummy\/app\/models\/b_dummy\.rb/)
      expect(result.values.uniq.size).to equal(1)
      expect(result.values.first).to eql({attribute_referenced: true})
    end
  end
end
