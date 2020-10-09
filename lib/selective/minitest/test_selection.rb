module Selective::MinitestSelectionPlugin
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

Minitest.singleton_class.send(:prepend, Selective::MinitestSelectionPlugin)
