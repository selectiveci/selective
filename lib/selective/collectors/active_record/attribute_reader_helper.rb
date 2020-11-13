# frozen_string_literal: true

module Selective
  module Collectors
    module ActiveRecord
      module AttributeReaderHelper
        def _read_attribute(attr_name)
          Selective.coverage_collectors[AttributeReaderCollector].add_covered_model(self.class)
          super
        end
      end
    end
  end
end
