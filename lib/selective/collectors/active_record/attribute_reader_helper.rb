# frozen_string_literal: true

module Selective
  module Collectors
    module ActiveRecord
      module AttributeReaderHelper
        def _read_attribute(_attr_name) # parameter passed to super
          Selective.coverage_collectors.fetch(AttributeReaderCollector).add_covered_models(self.class)
          super
        end
      end
    end
  end
end
