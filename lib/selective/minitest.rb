module Selective::MinitestPlugin
  def before_setup
    super
    Selective.collector.start_recording_code_coverage
  end

  def after_teardown
    Selective.collector.write_code_coverage_artifact
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
