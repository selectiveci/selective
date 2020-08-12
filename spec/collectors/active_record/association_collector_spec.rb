require "spec_helper"

RSpec.describe Selective::Collectors::ActiveRecord::AssociationCollector do
  module AssociationCollectorDummy
    def association(name)
      super unless Selective.call_dummy?
    end
  end

  describe "#set_hook" do
    before do
      allow(Selective).to receive(:enabled?).and_return(true)
      allow(Selective).to receive(:initialize_rspec_hooks)
      Selective.initialize_collectors
    end

    it "includes helper" do
      expect(ADummy.ancestors).to include(Selective::Collectors::ActiveRecord::AssociationHelper)
    end
  end

  describe "#data" do
    before do
      allow(Selective).to receive(:enabled?).and_return(true)
      allow(Selective).to receive(:initialize_rspec_hooks)
      Selective.initialize_collectors
      Selective.start_coverage
    end

    it "adds metadata" do
      a = ADummy.new
      a.association(:model_with_association)

      expect(Selective.coverage_collectors[described_class].covered_files).to have_value(association_referenced: true)
    end

    context "when selective is diabled" do
      before do
        allow_any_instance_of(described_class).to receive(:set_hook) do
          ActiveSupport.on_load(:active_record) do
            prepend AssociationCollectorDummy
          end
        end

        allow(Selective).to receive(:enabled?).and_return true
        allow(Selective).to receive(:call_dummy?).and_return true
        allow(Selective).to receive(:initialize_rspec_hooks)
        Selective.initialize_collectors
        Selective.start_coverage
      end

      it "does not add metadata" do
        a = ADummy.new
        a.association(:model_with_association)

        expect(Selective.coverage_collectors[described_class].covered_files).not_to have_value(association_referenced: true)
      end
    end
  end
end
