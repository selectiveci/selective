# frozen_string_literal: true

module Selective
  module Collectors
    module ActiveRecord
      module AttributeWriterHelper
        def _write_attribute(_attr_name, _value) # parameters passed to super
          Selective.coverage_collectors.fetch(AttributeWriterCollector).add_covered_models(self.class)
          super
        end
      end
    end
  end
end
