require "spec_helper"

RSpec.describe Selective::Collectors::SprocketsAssetCollector do
  let(:bad_asset_path) { 'xyz'}
  
  before do
    mock_double = double
    allow(mock_double).to receive(:metadata).and_return({dependencies: ['foo.js']})
    Rails.application.assets = {'foo.css' => mock_double}
  end

  describe "to collect" do
    let(:subject) { described_class.new(bad_asset_path).collect } 
    let(:expectation) { "Skipping asset xyz because it was not found in the cache\n" }

    it "handles bad asset path" do
        expect { subject }.to output(expectation).to_stdout
        expect(subject).to eql([])
    end

    context "with good asset path" do
        let(:subject) { described_class.new(asset_path).collect } 
        let(:asset_path) { "foo.css"}
        it 'handles asset path' do
            expect { subject }.not_to output(expectation).to_stdout
            expect(subject).to eql(["foo.js"])
        end
    end 
  end
end