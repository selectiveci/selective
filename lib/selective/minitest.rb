module Selective::MinitestPlugin
  def before_setup
    super
    Selective.collector.start_recording_code_coverage
  end

  def after_teardown
    test_method = self.class.instance_method(name.to_s)
    test_location = test_method.source_location.join(":")
    Selective.collector.write_code_coverage_artifact(test_location)
    super
  end
end

class Minitest::Test
  include Selective::MinitestPlugin
end

Minitest.after_run do
  puts 'Finalizing Selective results'
  Selective.collector.finalize
end
