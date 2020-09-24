# frozen_string_literal: true

require "selective/collectors/active_record/model_file_finder"

module Selective
  module Collectors
    module ActiveRecord
      class ModelCollector
        def initialize
          set_hook
        end

        def on_start
          @covered_model_collection = Set.new
        end

        def add_covered_models(*models)
          models.each { |model| model < ::ActiveRecord::Base }
          on_start unless covered_model_collection

          covered_model_collection.merge(models)
        end

        def covered_files
          {}.tap do |coverage_data|
            covered_model_collection.each do |model|
              file = ModelFileFinder.new.file_path(model)
              next if file.nil?

              coverage_data[file] = data
            end

            on_start
          end
        end

        private

        attr_reader :covered_model_collection

        def set_hook
          raise "Not Implemented"
        end

        def data
        end
      end
    end
  end
end
