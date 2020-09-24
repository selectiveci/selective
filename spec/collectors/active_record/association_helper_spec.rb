require "spec_helper"

RSpec.describe Selective::Collectors::ActiveRecord::AssociationHelper do
  class AssociationHelperDummy
    def association(txt)
      raise "Not text" unless txt.is_a?(String)
      '34567'
    end

    prepend Selective::Collectors::ActiveRecord::AssociationHelper
  end

  let(:base) { Selective.coverage_collectors.fetch(Selective::Collectors::ActiveRecord::AssociationCollector) }
  before do
    base.on_start
  end

  describe "#association" do
    it "ensures association calls super" do
      result = AssociationHelperDummy.new.association('abc')

      expect(result).to eql('34567')

      expect(base.instance_variable_get("@covered_model_collection")).not_to be_empty
    end
  end
end