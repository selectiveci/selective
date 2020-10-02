module Selective::MinitestSelectionPlugin
  def run(args = [])
    puts "run"
    Selective.selected_tests = Selective::Selector.tests_from_diff
    super
  end

  def run_one_method(klass, runnable_method)
    puts "klass: #{klass}"
    puts "runnable_method: #{runnable_method}"
    puts "Selective.selected_tests: #{Selective.selected_tests}"
    test_method = klass.instance_method(runnable_method.to_s)
    test_location = test_method.source_location.join(':')
    puts "test_location: #{test_location}"
    if Selective.selected_tests.blank? || (Selective.selected_tests & [test_location]).any?
      output = super
      puts "output: #{output.inspect}"
      output
    else
      Selective.skipped_tests << test_location
      "#{klass}\##{runnable_method}"
    end
  end
end

Minitest.singleton_class.send(:prepend, Selective::MinitestSelectionPlugin)
