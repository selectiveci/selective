require "spec_helper"

RSpec.describe Selective::Collectors::ActionView::RenderedTemplateCollector do
  class DummyView < ActionView::Base
  end

  describe "#add_covered_templates" do
    context "when selective is not enabled" do
      it "is not called" do
        expect_any_instance_of(described_class).not_to receive(:add_covered_templates)

        view = DummyView.new(::ActionView::LookupContext.new(["spec/dummy/app/views"]), {})
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
        view = DummyView.new(::ActionView::LookupContext.new(["spec/dummy/app/views"]), {})

        expect(mock_collector).to receive(:add_covered_templates).with(view.lookup_context.find_template("foo.html.erb").identifier)
        described_class.subscribe(mock_collector)
        expect(described_class.subscriber).not_to be_nil

        view.render(template: "foo.html.erb")
      end
    end
  end
end
