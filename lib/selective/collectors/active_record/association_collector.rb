# frozen_string_literal: true

require "selective/collectors/active_record/model_collector"
require "selective/collectors/active_record/association_helper"

module Selective
  module Collectors
    module ActiveRecord
      class AssociationCollector < ModelCollector
        private

        DATA = {association_referenced: true}.freeze

        def set_hook
          ActiveSupport.on_load(:active_record) do
            include AssociationHelper
          end
        end

        def data
          DATA
        end
      end
    end
  end
end
