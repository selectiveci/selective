# frozen_string_literal: true

module Selective
  module Collectors
    module Webpacker
      module Helpers
        ERROR_MESSAGE = "Selective.config.webpacker_app_locations must be set to collect webpacker app coverage"

        def javascript_packs_with_chunks_tag(*names, **options)
          precheck_locations_set

          globs = names.flat_map do |name|
            app_home = javascript_app_home(name)
            raise("Unable to locate source location for javascript app #{name}") unless app_home

            [
              File.join(app_home, "src", "**.{scss,css,js}"),
              File.join(app_home, "package*.json")
            ]
          end
          Selective.coverage_collectors.fetch(WebpackerAppCollector).add_covered_globs(*globs)
          super
        end

        def javascript_app_home(name)
          Selective.config.webpacker_app_locations.map { |potential_app_root|
            File.join(potential_app_root, name)
          }.detect do |potential_app_home|
            Dir.exist?(potential_app_home)
          end
        end

        def precheck_locations_set
          return if Selective.config.webpacker_app_locations.any?

          raise(ERROR_MESSAGE)
        end
      end
    end
  end
end
