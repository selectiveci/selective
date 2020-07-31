# frozen_string_literal: true

require 'test_helper'

module Selective
  module Collectors
    module ActiveRecord
      class AttributeWriterHelperTest < ActiveSupport::TestCase
        def setup
          Selective.stubs(:single_test_coverage_enabled?).returns(true)
          Selective.stubs(:whole_test_suite_coverage_enabled?).returns(false)
          Selective.start_coverage
        end

        def test_attribute_reader
          @mock_collector = mock
          Selective.coverage_collectors = {
            AttributeWriterCollector => @mock_collector
          }

          @mock_collector.expects(:add_covered_models).never
          a_dummy = ADummy.new
          a_dummy.attr1 = 'dumb'

          @mock_collector.expects(:add_covered_models).with(ADummy)
          a_dummy.extend(Selective::Collectors::ActiveRecord::AttributeWriterHelper)
          a_dummy.attr1 = 'and dumber'
        end
      end
    end
  end
end
