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

        def add_covered_model(model)
          @covered_model_collection&.add(model.name)
        end

        def covered_files
          {}.tap do |coverage_data|
            @covered_model_collection.each do |model_name|
              file = ModelFileFinder.new.file_path(model_name)
              Thread.current[(model_name + "-selective-selective").to_sym] = nil
              next if file.nil?

              coverage_data[file] = data
            end
          end
        end

        private

        def set_hook
          raise "Not Implemented"
        end

        def data
          nil
        end
      end
    end
  end
end
