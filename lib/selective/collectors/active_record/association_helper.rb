# frozen_string_literal: true

module Selective
  module Collectors
    module ActiveRecord
      module AssociationHelper
        def association(_name) # parameter passed to super
          Selective.coverage_collectors.fetch(AssociationCollector).add_covered_models(self.class)
          super
        end
      end
    end
  end
end
