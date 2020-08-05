require "spec_helper"

RSpec.describe Selective::Collectors::ActiveRecord::AttributeReaderHelper do
  let(:mock_collector) { double }

  before do
    allow(Selective).to receive(:coverage_collectors).and_return({
      described_class.parent::AttributeReaderCollector => mock_collector
    })

    Selective.start_coverage
  end

  describe "#add_covered_models" do
    context 'when selective is not enabled' do
      it 'is not called' do
        expect(mock_collector).not_to receive(:add_covered_models)

        a_dummy = ADummy.new
        a_dummy.attr1
      end
    end

    context 'when selective is enabled' do
      it 'is called' do
        expect(mock_collector).to receive(:add_covered_models).with(ADummy)

        a_dummy = ADummy.new
        a_dummy.extend(described_class)
        a_dummy.attr1
      end
    end
  end
end
