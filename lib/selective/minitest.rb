module Selective
  module Minitest
    module Reporting
      module Plugin
        def before_setup
          super
          Selective.collector.start_recording_code_coverage
        end

        def after_teardown
          test_identifier = "#{self.class}##{name}"
          Selective.collector.write_code_coverage_artifact(test_identifier)
          super
        end
      end

      def self.hook
        ::Minitest::Test.send(:include, Selective::Minitest::Reporting::Plugin)

        ::Minitest.after_run do
          Selective.collector.finalize
        end
      end
    end

    module Selection
      module Plugin
        # Alter process_args to insert a name filter into the arguments list
        # This will override any other name filters that are passed
        def process_args(args = [])
          Selective.selected_tests = Selective::Selector.tests_from_diff
          if Selective.selected_tests.any?
            regex = '/' + Selective.selected_tests.join('|') + '/'
            args.concat(['--name', regex])
          end
          super
        end
      end

      def self.hook
        ::Minitest.singleton_class.send(:prepend, Selective::Minitest::Selection::Plugin)
      end
    end
  end
end
