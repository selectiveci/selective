require "spec_helper"

RSpec.describe Selective::Collectors::ActiveRecord::AttributeReaderHelper do
  let(:collector) { Selective.coverage_collectors[Selective::Collectors::ActiveRecord::AttributeReaderCollector] }

  module AttributeReaderHelperDummy
    def _read_attribute(attr_name)
      if Selective.call_dummy?
        method(__method__).super_method.super_method.call(attr_name)
      else
        super
      end
    end
  end

  before do
    Selective.coverage_collectors[described_class] = collector
  end

  before(:each, :full_setup) do
    allow(Selective).to receive(:enabled?).and_return true
    allow(Selective).to receive(:initialize_rspec_hooks)
    Selective.initialize_collectors
  end

  describe "#add_covered_models" do
    context 'when selective is disabled' do
      let(:collector) { double }

      before do
        allow_any_instance_of(Selective::Collectors::ActiveRecord::AttributeReaderCollector).to receive(:set_hook) do
          ActiveSupport.on_load(:active_record) do
            prepend AttributeReaderHelperDummy
          end
        end

        allow(Selective).to receive(:enabled?).and_return true
        allow(Selective).to receive(:call_dummy?).and_return true
        allow(Selective).to receive(:initialize_rspec_hooks)
        Selective.initialize_collectors
      end

      it 'is not called' do
        expect(collector).not_to receive(:add_covered_models)

        a_dummy = ADummy.new
        a_dummy.attr1
      end
    end

    context 'when selective is enabled', :full_setup do
      it 'is called' do
        expect(collector).to receive(:add_covered_models).with(ADummy)

        a_dummy = ADummy.new
        a_dummy.attr1
      end

      it 'is not called on attributes that don\'t exist' do
        expect(collector).not_to receive(:add_covered_models)

        a_dummy = ADummy.new
        expect { a_dummy.attr2 }.to raise_error(NoMethodError)
      end
    end
  end
end
