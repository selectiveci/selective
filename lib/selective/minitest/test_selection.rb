module Selective::MinitestSelectionPlugin
  def process_args(args = [])
    Selective.selected_tests = Selective::Selector.tests_from_diff
    if Selective.selected_tests.any?
      regex = '/' + Selective.selected_tests.join("|") + '/'
      args.concat(['-n', regex])
    end
    super
  end
end

Minitest.singleton_class.send(:prepend, Selective::MinitestSelectionPlugin)
