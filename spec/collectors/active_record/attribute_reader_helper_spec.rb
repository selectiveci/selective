require "spec_helper"

RSpec.describe Selective::Collectors::ActiveRecord::AttributeReaderHelper do
  let(:collector) { Selective.coverage_collectors[Selective::Collectors::ActiveRecord::AttributeReaderCollector] }

  before(:each, :full_setup) do
    allow(Selective).to receive(:enabled?).and_return true
    allow(Selective).to receive(:initialize_rspec_hooks)
    Selective.initialize_collectors
  end

  describe "#add_covered_models" do
    context 'when selective is not enabled' do
      let(:collector) { double }

      before do
        allow(Selective).to receive(:coverage_collectors).and_return({
          described_class.parent::AttributeReaderCollector => collector
        })
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
