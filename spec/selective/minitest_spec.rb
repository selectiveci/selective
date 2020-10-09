require "spec_helper"
require "selective"

RSpec.describe Selective::Minitest do
  describe Selective::Minitest::Reporting do
    describe '.hook' do
      it 'includes the reporting plugin' do
        expect(::Minitest::Test).to receive(:include).
          with(Selective::Minitest::Reporting::Plugin)
        Selective::Minitest::Reporting.hook
      end
    end
  end

  describe Selective::Minitest::Selection do
    describe '.hook' do
      it 'prepends the selection plugin' do
        expect(::Minitest.singleton_class).to receive(:prepend).
          with(Selective::Minitest::Selection::Plugin)
        Selective::Minitest::Selection.hook
      end
    end
  end
end
