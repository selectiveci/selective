# frozen_string_literal: true

module Selective
  module Collectors
    module ActiveRecord
      class ModelFileFinder
        MODEL_LOCATION = "app/models"

        def file_path(model)
          Rails.application.paths[MODEL_LOCATION].each do |model_root|
            path = Rails.root.join(model_root, "#{model.name.underscore}.rb").to_s
            return path if File.exist?(path)
          end
          Rails::Engine.subclasses.each do |engine|
            engine.paths[MODEL_LOCATION].each do |model_root|
              path = engine.root.join(model_root, "#{model.name.underscore}.rb").to_s
              return path if File.exist?(path)
            end
          end

          nil
        end
      end
    end
  end
end
