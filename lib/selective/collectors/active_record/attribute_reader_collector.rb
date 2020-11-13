# frozen_string_literal: true

require "selective/collectors/active_record/model_collector"
require "selective/collectors/active_record/attribute_reader_helper"

module Selective
  module Collectors
    module ActiveRecord
      class AttributeReaderCollector < ModelCollector
        private

        def set_hook
          ActiveSupport.on_load(:active_record) do
            include AttributeReaderHelper
          end
        end

        def data
          # once per model
          {attribute_referenced: true}
        end
      end
    end
  end
end
