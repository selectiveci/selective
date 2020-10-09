# frozen_string_literal: true

require "spec_helper"
require "selective"

RSpec.describe Selective::Selector do
  describe ".tests_from_diff" do
    let(:repository_return_value) { {"default_branch_name" => "foo-bar-branch-name"} }
    let(:test_from_diff_return_value) { {"tests" => [:foo, :bar]} }
    let(:system_call_return_value) { "foobar" }

    before do
      allow(Selective::Api).to receive(:request).with("repository", method: :get).and_return(repository_return_value)
      allow(Selective::Api).to receive(:request).with("call_graphs/tests_from_diff", anything, method: :post).and_return(test_from_diff_return_value)

      allow(Selective::Selector).to receive(:`).and_return(system_call_return_value)
    end

    it "returns an array of specs" do
      expected_request_body = {
        git_branch: repository_return_value["default_branch_name"],
        sha: system_call_return_value,
        diff: system_call_return_value
      }
      expect(described_class.tests_from_diff).to eq(test_from_diff_return_value["tests"])
      expect(Selective::Api).to have_received(:request).with("call_graphs/tests_from_diff", expected_request_body, method: :post)
    end
  end

  describe ".default_branch_name" do
    let(:repository_return_value) { {"default_branch_name" => "foo-bar-branch-name"} }
    let(:test_from_diff_return_value) { {"tests" => [:foo, :bar]} }
    let(:system_call_return_value) { "foobar" }

    before do
      allow(Selective::Api).to receive(:request).with("repository", method: :get).and_return(repository_return_value)
      allow(Selective::Api).to receive(:request).with("call_graphs/tests_from_diff", anything, method: :post).and_return(test_from_diff_return_value)

      allow(Selective::Selector).to receive(:`).and_return(system_call_return_value)
    end

    it "returns the default branch name" do
      expect(described_class.default_branch_name).to eql("foo-bar-branch-name")
    end
  end

  describe ".git_diff_cmd" do
    let(:repository_return_value) { {"default_branch_name" => "foo-bar-branch-name"} }
    let(:test_from_diff_return_value) { {"tests" => [:foo, :bar]} }
    let(:expected_cmd) { "git fetch origin foo-bar-branch-name && git diff origin/foo-bar-branch-name" }

    before do
      allow(Selective::Api).to receive(:request).with("repository", method: :get).and_return(repository_return_value)
      allow(Selective::Api).to receive(:request).with("call_graphs/tests_from_diff", anything, method: :post).and_return(test_from_diff_return_value)
    end

    it "returns the git diff" do
      expect(described_class.git_diff_cmd).to eql(expected_cmd)
    end
  end

  describe ".git_diff" do
    let(:repository_return_value) { {"default_branch_name" => "foo-bar-branch-name"} }
    let(:test_from_diff_return_value) { {"tests" => [:foo, :bar]} }
    let(:system_call_return_value) { "foobar" }
    let(:expected_cmd) { "git fetch origin foo-bar-branch-name && git diff origin/foo-bar-branch-name" }

    before do
      allow(Selective::Api).to receive(:request).with("repository", method: :get).and_return(repository_return_value)
      allow(Selective::Api).to receive(:request).with("call_graphs/tests_from_diff", anything, method: :post).and_return(test_from_diff_return_value)

      allow(Selective::Selector).to receive(:`).and_return(system_call_return_value)
    end

    it "returns the git diff" do
      expect(described_class.git_diff).to eql('foobar')
    end
  end
end
