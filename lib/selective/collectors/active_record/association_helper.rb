# frozen_string_literal: true

module Selective
  module Collectors
    module ActiveRecord
      module AssociationHelper
        def association(name)
          Selective.coverage_collectors.fetch(AssociationCollector).add_covered_models(self.class)
          super
        end
      end
    end
  end
end
