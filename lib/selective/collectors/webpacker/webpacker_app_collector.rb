# frozen_string_literal: true

require "selective/collectors/webpacker/helpers"

module Selective
  module Collectors
    module Webpacker
      class WebpackerAppCollector
        def initialize
          ActiveSupport.on_load(:action_view) do
            prepend Helpers
          end
        end

        def on_start
          @covered_globs = Set.new
        end

        def add_covered_globs(*globs)
          covered_globs.merge(globs)
        end

        def covered_files
          {}.tap do |coverage_data|
            covered_globs.each do |glob_pattern|
              coverage_data[glob_pattern] = {glob: true}
            end
          end
        end

        private

        attr_reader :covered_globs
      end
    end
  end
end
