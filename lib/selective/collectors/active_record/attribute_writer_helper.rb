# frozen_string_literal: true

module Selective
  module Collectors
    module ActiveRecord
      module AttributeWriterHelper
        def _write_attribute(attr_name, value)
          Thread.current["#{self.class.name}-selective-selective".to_sym] ||= Selective.coverage_collectors[AttributeWriterCollector].add_covered_model(self.class)
          super
        end
      end
    end
  end
end
