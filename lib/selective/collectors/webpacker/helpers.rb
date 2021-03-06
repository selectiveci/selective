# frozen_string_literal: true

module Selective
  module Collectors
    module Webpacker
      module Helpers
        def javascript_packs_with_chunks_tag(*names, **options)
          if Selective.config.webpacker_app_locations.blank?
            raise(StandardError, "Selective.config.webpacker_app_locations must be set to collect webpacker app coverage")
          end

          globs = names.flat_map { |name|
            app_home = javascript_app_home(name)
            unless Dir.exist?(app_home)
              raise(StandardError, "Unable to locate source location for javascript app #{name}")
            end

            [
              File.join(app_home, "src", "**.{scss,css,js}"),
              File.join(app_home, "package*.json")
            ]
          }
          Selective.coverage_collectors[WebpackerAppCollector].add_covered_globs(*globs)
          super
        end

        def javascript_app_home(name)
          Selective.config.webpacker_app_locations.map { |potential_app_root|
            File.join(potential_app_root, name)
          }.detect do |potential_app_home|
            Dir.exist?(potential_app_home)
          end
        end
      end
    end
  end
end
