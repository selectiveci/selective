require "spec_helper"

RSpec.describe Selective::Collectors::ActionView::RenderedTemplateCollector do
  let(:view_path) { "spec/dummy/app/views" }

  describe "#add_covered_templates" do
    context "when selective is disabled" do
      before do
        described_class.unsubscribe
      end

      it "is not called" do
        expect_any_instance_of(described_class).not_to receive(:add_covered_templates)

        view = DummyView.new(::ActionView::LookupContext.new([view_path]), {})
        view.render(template: "foo")
      end
    end

    context "when selective is enabled" do
      after do
        described_class.unsubscribe
        expect(described_class.subscriber).to be_nil
      end

      it "is called" do
        mock_collector = double
        view = DummyView.new(::ActionView::LookupContext.new([view_path]), {})

        expect(mock_collector).to receive(:add_covered_templates).with(view.lookup_context.find_template("foo.html.erb").identifier)
        described_class.subscribe(mock_collector)
        expect(described_class.subscriber).not_to be_nil

        view.render(template: "foo.html.erb")
      end
    end
  end

  describe "#covered_files" do
    before do
      allow(Selective).to receive(:enabled?).and_return true
      allow(Selective).to receive(:initialize_rspec_hooks)
      Selective.initialize_collectors
      Selective.start_coverage
    end

    it "keeps track of covered files" do
      view = DummyView.new(::ActionView::LookupContext.new([view_path]), {})
      view.render(template: "foo")

      covered_files = Selective.coverage_collectors[described_class].covered_files
      expect(covered_files.length).to eq(1)
      expect(covered_files.keys.first).to include("#{view_path}/foo.html.erb")
      expect(covered_files.values.first).to eq(template: true)
    end
  end

  describe "#unsubscribe" do
    before do
      allow(Selective).to receive(:enabled?).and_return true
      allow(Selective).to receive(:initialize_rspec_hooks)
      Selective.initialize_collectors
    end

    it "sets subscriber to nil" do
      described_class.unsubscribe
      expect(described_class.subscriber).to be_nil
    end
  end
end
