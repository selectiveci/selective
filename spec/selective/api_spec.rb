require 'spec_helper'

RSpec.describe Selective::Api do
  let(:host) { 'host.docker.internal:3000' }

  it 'defines HOST constant' do
    expect(Selective::Api::HOST).to eq("http://#{host}")
  end

  describe '.request' do
    subject(:request) { Selective::Api.request('repository') }

    let(:api_key) { 'abc123' }
    let(:response_body_hash) do
      { 'foo' => 'bar' }
    end

    before do
      allow(Selective.config).to receive(:api_key).and_return(api_key)
      stub_request(:get, "#{host}/api/v1/repository").
        with(headers: { :'Content-Type' => 'application/json', 'X-API-KEY' => api_key }).
        to_return(body: response_body_hash.to_json)
    end

    it 'returns a parsed hash of the JSON response body' do
      expect(request).to eq(response_body_hash)
    end
  end
end
