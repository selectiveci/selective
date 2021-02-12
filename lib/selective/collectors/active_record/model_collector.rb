# frozen_string_literal: true

require "selective/collectors/active_record/model_file_finder"

module Selective
  module Collectors
    module ActiveRecord
      class ModelCollector
        attr_reader :seconds_adding_covered

        def initialize
          set_hook
          @seconds_adding_covere = 0
        end

        def on_start
          @covered_model_collection = Set.new
          @seconds_adding_covered = 0
        end

        def add_covered_models(*models)
          t = Time.now
          @covered_model_collection&.merge(models)
          @seconds_adding_covered += (Time.now - t)
        end

        def covered_files
          {}.tap do |coverage_data|
            @covered_model_collection.each do |model|
              file = ModelFileFinder.new.file_path(model)
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
