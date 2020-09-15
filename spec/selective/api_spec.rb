require "spec_helper"

RSpec.describe Selective::Api do
  subject(:request) { Selective::Api.request("repository", method: method) }
  let(:host) { Selective.config.backend_host }

  describe ".request" do
    let(:api_key) { "abc123" }
    let(:response_body_hash) do
      {"foo" => "bar"}
    end

    [:get, :post].each do |method|
      context "when the method is #{method}" do
        let(:method) { method }

        before do
          allow(Selective.config).to receive(:api_key).and_return(api_key)
          stub_request(method, "#{host}/api/v1/repository")
            .with(headers: {:'Content-Type' => "application/json", "X-API-KEY" => api_key})
            .to_return(body: response_body_hash.to_json)
        end

        it "returns a parsed hash of the JSON response body" do
          expect(request).to eq(response_body_hash)
        end
      end
    end

    context "when the method is invalid" do
      let(:method) { "foobar" }

      it "raises an error" do
        expect { request }.to raise_error("Invalid method")
      end
    end
  end
end
