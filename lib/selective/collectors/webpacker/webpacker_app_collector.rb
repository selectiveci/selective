# frozen_string_literal: true

require "selective/collectors/webpacker/helpers"

module Selective
  module Collectors
    module Webpacker
      class WebpackerAppCollector
        attr_reader :seconds_adding_covered

        def initialize
          ActiveSupport.on_load(:action_view) do
            prepend Selective::Collectors::Webpacker::Helpers
          end
          @seconds_adding_covered = 0
        end

        def on_start
          @covered_globs = Set.new
        end

        def add_covered_globs(*globs)
          t = Time.now
          @covered_globs&.merge(globs)
          @seconds_adding_covered += (Time.now - t)
        end

        def clear_timer
          @seconds_adding_covered = 0
        end

        def covered_files
          {}.tap do |coverage_data|
            @covered_globs.each do |glob_pattern|
              coverage_data[glob_pattern] = {glob: true}
            end
          end
        end
      end
    end
  end
end
