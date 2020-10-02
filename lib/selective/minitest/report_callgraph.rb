module Selective::MinitestReportingPlugin
  def before_setup
    super
    Selective.collector.start_recording_code_coverage
  end

  def after_teardown
    #test_method = self.class.instance_method(name.to_s)
    #test_location = test_method.source_location.join(':')
    test_identifier = "#{self.class}##{name}"
    puts "test_identifier: #{test_identifier}"
    Selective.collector.write_code_coverage_artifact(test_identifier)
    super
  end
end

class Minitest::Test
  include Selective::MinitestReportingPlugin
end

Minitest.after_run do
  puts 'Finalizing Selective collector results'
  Selective.collector.finalize
end
