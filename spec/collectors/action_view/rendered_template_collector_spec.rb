require "spec_helper"

RSpec.describe Selective::Collectors::ActionView::RenderedTemplateCollector do
  let(:view_path) { "spec/dummy/app/views" }
  let(:collector) { Selective.coverage_collectors.fetch(described_class) }

  after do
    described_class.unsubscribe
  end

  describe "#add_covered_templates" do
    context "when selective is disabled" do
      before do
        allow(Selective).to receive(:report_callgraph?).and_return true
        allow(Selective).to receive(:initialize_rspec_reporting_hooks)

        Selective.initialize_collectors
        described_class.unsubscribe
      end

      it "is not called" do
        expect(collector).not_to receive(:add_covered_templates)

        view = DummyView.new(::ActionView::LookupContext.new([view_path]), {})
        view.render(template: "foo")
      end
    end

    context "when selective is enabled" do
      before do
        allow(Selective).to receive(:report_callgraph?).and_return true
        allow(Selective).to receive(:initialize_rspec_reporting_hooks)

        Selective.initialize_collectors
        Selective.start_coverage
      end

      it "is called" do
        mock_collector = double
        mock_collector2 = double
        view = DummyView.new(::ActionView::LookupContext.new([view_path]), {})

        expect(mock_collector2).not_to receive(:add_covered_templates).with(view.lookup_context.find_template("foo.html.erb").identifier)
        # expect(collector).to receive(:add_covered_templates).with(view.lookup_context.find_template("foo.html.erb").identifier)
        expect(collector).to receive(:on_start).once

        described_class.subscribe(mock_collector2)
        described_class.subscribe(mock_collector)

        expect(described_class.subscriber).to be_an_instance_of(ActiveSupport::Notifications::Fanout::Subscribers::Timed)

        view.render(template: "foo.html.erb")

        files = collector.covered_files

        expect(files).to be_an_instance_of(Hash)
        expect(files.keys.first).to eql(view.lookup_context.find_template("foo.html.erb").identifier)
        expect(files.values.first).to eql({template: true})

        described_class.unsubscribe
        described_class.unsubscribe
      end
    end
  end

  describe "#covered_files" do
    before do
      allow(Selective).to receive(:report_callgraph?).and_return true
      allow(Selective).to receive(:initialize_rspec_reporting_hooks)

      Selective.initialize_collectors
      described_class.subscribe(collector)
    end

    it "keeps track of covered files" do
      view = DummyView.new(::ActionView::LookupContext.new([view_path]), {})
      view.render(template: "foo.html.erb")
      view.render(template: "foo2.html.erb")

      covered_files = collector.covered_files

      expect(covered_files.length).to eq(2)
      expect(covered_files.keys.first).to include("#{view_path}/foo.html.erb")
      expect(covered_files.values.first).to eql(template: true)

      covered_files = collector.covered_files
      expect(covered_files.length).to eq(0)
    end
  end

  describe ".unsubscribe" do
    before do
      allow(Selective).to receive(:report_callgraph?).and_return true
      allow(Selective).to receive(:initialize_rspec_reporting_hooks)
      Selective.initialize_collectors
    end

    it "sets subscriber to nil" do
      described_class.unsubscribe

      expect(described_class.subscriber).to be_nil
    end

    it "unsubscribes" do
      described_class.subscribe(collector)

      subscriber = described_class.subscriber
      expect(subscriber).to be_an_instance_of(ActiveSupport::Notifications::Fanout::Subscribers::Timed)

      expect(ActiveSupport::Notifications).to receive(:unsubscribe).with(subscriber)
      described_class.unsubscribe
    end
  end

  describe "subscribe" do
    it 'subscribes' do
      orig_subscriber = described_class.subscriber
      expect(orig_subscriber).to be_nil

      described_class.subscribe(described_class.new)
      
      subscriber = described_class.subscriber
      expect(subscriber).to be_an_instance_of(ActiveSupport::Notifications::Fanout::Subscribers::Timed)
    end
  end

  describe "#initialize" do
    it 'subscribes' do
      expect(described_class.subscriber).to be_nil
      
      described_class.new

      subscriber = described_class.subscriber
      expect(subscriber).to be_an_instance_of(ActiveSupport::Notifications::Fanout::Subscribers::Timed)
    end

    it 'subscribes' do
      described_class.subscribe(described_class.new)
      orig_subscriber = described_class.subscriber

      described_class.new

      subscriber = described_class.subscriber
      expect(subscriber).to be_an_instance_of(ActiveSupport::Notifications::Fanout::Subscribers::Timed)

      expect(subscriber).to equal(orig_subscriber)
    end
  end
end
