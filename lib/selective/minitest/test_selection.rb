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
    if true || Selective.selected_tests.blank? || (Selective.selected_tests & [example.id, example.file_path]).any?
      super
    else
      Selective.skipped_tests << example.id
    end
  end
end

Minitest.singleton_class.send(:prepend, Selective::MinitestSelectionPlugin)
