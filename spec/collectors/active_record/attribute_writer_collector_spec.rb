require "spec_helper"

RSpec.describe Selective::Collectors::ActiveRecord::AttributeWriterCollector do
  module AttributeWriterCollectorDummy
    include DummyHelpers

    def _write_attribute(attr_name, value)
      if Selective.call_dummy?
        find_proper_method("ActiveRecord::AttributeMethods::Write#_write_attribute", method(__method__).super_method, attr_name, value)
      else
        super
      end
    end
  end

  let(:collector) { Selective.coverage_collectors[described_class] }

  describe "#set_hook" do
    context "when selective is disabled" do
      before do
        allow_any_instance_of(described_class).to receive(:set_hook) do
          ActiveSupport.on_load(:active_record) do
            prepend AttributeWriterCollectorDummy
          end
        end

        allow(Selective).to receive(:enabled?).and_return true
        allow(Selective).to receive(:call_dummy?).and_return true
        allow(Selective).to receive(:initialize_rspec_hooks)

        Selective.initialize_collectors
        Selective.start_coverage
      end

      it "is not called" do
        expect_any_instance_of(ActiveRecord::AttributeMethods::Write).to receive(:_write_attribute)
        a = ADummy.new
        a.attr1 = 'foobar'
      end
    end

    context "when selective is enabled" do
      before do
        allow(Selective).to receive(:enabled?).and_return true
        allow(Selective).to receive(:initialize_rspec_hooks)

        Selective.initialize_collectors
        Selective.start_coverage
      end

      it "is called" do
        expect(collector).to receive(:add_covered_models)
        a = ADummy.new
        a.attr1 = 'foobar'
      end
    end
  end

  describe "#data" do
    before do
      allow(Selective).to receive(:enabled?).and_return true
      allow(Selective).to receive(:initialize_rspec_hooks)

      Selective.initialize_collectors
      Selective.start_coverage
    end

    it "adds metadata" do
      a = ADummy.new
      a.attr1 = 'foobar'

      expect(collector.covered_files).to have_value(attribute_written: true)
    end
  end
end
