require "spec_helper"
require "selective"

RSpec.describe Selective::Minitest do
  class ReportingPluginTesterSuperclass
    def before_setup
      @super_before_setup_called = true
    end

    def after_teardown
      @super_after_teardown_called = true
    end
  end

  class ReportingPluginTester < ReportingPluginTesterSuperclass
    def name
      'sample_test_method'
    end

    include Selective::Minitest::Reporting::Plugin
  end

  class SelectionPluginTesterSuperclass
    def process_args(args=[])
      @superclass_args = args
    end
  end

  class SelectionPluginTester < SelectionPluginTesterSuperclass
    include Selective::Minitest::Selection::Plugin
  end

  describe Selective::Minitest::Reporting do
    describe Selective::Minitest::Reporting::Plugin do
      let(:reporting_plugin_tester) { ReportingPluginTester.new }

      before do
        allow(Selective).to receive(:collector).and_return(double)
      end

      describe '#before_setup' do
        it 'calls superclass before_setup and starts recording code coverage' do
          expect(Selective.collector).to receive(:start_recording_code_coverage)
          reporting_plugin_tester.before_setup
          expect(reporting_plugin_tester.instance_variable_get(:@super_before_setup_called)).to be true
        end
      end

      describe '#after_teardown' do
        let(:test_identifier) { 'ReportingPluginTester#sample_test_method' }

        it 'writes code coverage artifact and calls super' do
          expect(Selective.collector).to receive(:write_code_coverage_artifact).with(test_identifier)
          reporting_plugin_tester.after_teardown
          expect(reporting_plugin_tester.instance_variable_get(:@super_after_teardown_called)).to be true
        end
      end
    end

    describe '.hook' do
      it 'includes the reporting plugin' do
        expect(::Minitest::Test).to receive(:include).
          with(Selective::Minitest::Reporting::Plugin)
        Selective::Minitest::Reporting.hook
      end

      it 'add finalize as an after_run' do
        expect(::Minitest).to receive(:after_run)
        Selective::Minitest::Reporting.hook
      end
    end
  end

  describe Selective::Minitest::Selection do
    describe Selective::Minitest::Selection::Plugin do
      let(:selection_plugin_tester) { SelectionPluginTester.new }
      let(:superclass_args) { selection_plugin_tester.instance_variable_get(:@superclass_args) }

      context 'when selected tests are returned' do
        it 'inserts name filter args from selected tests' do
          expect(Selective::Selector).to receive(:tests_from_diff) do
            [
              'SampleTestClass#sample_test_method1',
              'SampleTestClass#sample_test_method2'
            ]
          end
          selection_plugin_tester.process_args(['--foo', 'bar'])
          expect(superclass_args).to eq(
            [
              '--foo',
              'bar',
              '--name',
              '/SampleTestClass#sample_test_method1|SampleTestClass#sample_test_method2/',
            ]
          )
        end
      end

      context 'when no selected tests returned' do
        it 'does not alter args' do
          expect(Selective::Selector).to receive(:tests_from_diff).and_return([])
          selection_plugin_tester.process_args(['--foo', 'bar'])
          expect(superclass_args).to eq(['--foo', 'bar'])
        end
      end
    end

    describe '.hook' do
      it 'prepends the selection plugin' do
        expect(::Minitest.singleton_class).to receive(:prepend).
          with(Selective::Minitest::Selection::Plugin)
        Selective::Minitest::Selection.hook
      end
    end
  end
end
