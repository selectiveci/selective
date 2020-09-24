require "spec_helper"

RSpec.describe Selective::Collectors::ActiveRecord::AttributeWriterHelper do
  module AttributeWriterHelperDummy
    include DummyHelpers

    def _write_attribute(attr_name, value)
      if Selective.call_dummy?
        find_proper_method("ActiveRecord::AttributeMethods::Write#_write_attribute", method(__method__).super_method, attr_name, 'xyz')
      else
        super
      end
    end
  end

  before(:each, :full_setup) do
    allow(Selective).to receive(:report_callgraph?).and_return true
    allow(Selective).to receive(:initialize_rspec_reporting_hooks)

    Selective.initialize_collectors
  end

  describe "#add_covered_models" do
    context "when selective is disabled" do
      let(:collector) { double }

      before do
        allow_any_instance_of(Selective::Collectors::ActiveRecord::AttributeWriterCollector).to receive(:set_hook) do
          ActiveSupport.on_load(:active_record) do
            include AttributeWriterHelperDummy
          end
        end

        allow(Selective).to receive(:report_callgraph?).and_return true
        allow(Selective).to receive(:call_dummy?).and_return true
        allow(Selective).to receive(:initialize_rspec_reporting_hooks)
        Selective.initialize_collectors
      end

      it "is not called" do
        expect_any_instance_of(described_class).not_to receive(:_write_attribute)

        a_dummy = ADummy.new
        a_dummy.attr1 = 'xyz'
      end
    end

    context "when selective is enabled", :full_setup do
      it "is called" do
        expect_any_instance_of(Selective::Collectors::ActiveRecord::AttributeWriterCollector).to receive(:add_covered_models).with(ADummy)

        a_dummy = ADummy.new
        a_dummy.attr1 = 'xyz'

        expect(a_dummy.attr1).to eql('xyz')
      end

      it "is not called on attributes that don't exist" do
        expect_any_instance_of(Selective::Collectors::ActiveRecord::AttributeWriterCollector).not_to receive(:add_covered_models)

        a_dummy = ADummy.new
        expect { a_dummy.attr2 }.to raise_error(NoMethodError)
      end
    end
  end
end
