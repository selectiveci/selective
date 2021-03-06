# frozen_string_literal: true

module Selective
  module Collectors
    module ActionView
      class RenderedTemplateCollector
        class << self
          attr_reader :subscriber

          def subscribe(collector)
            @subscriber = ActiveSupport::Notifications.subscribe("!render_template.action_view") { |_name, _start, _finish, _id, payload|
              collector.add_covered_templates(payload[:identifier])
            }
          end

          def unsubscribe
            return unless @subscriber

            ActiveSupport::Notifications.unsubscribe(@subscriber)
            @subscriber = nil
          end
        end

        def initialize
          RenderedTemplateCollector.subscribe(self) unless RenderedTemplateCollector.subscriber.present?
        end

        def on_start
          @covered_templates_collection = Set.new
        end

        def add_covered_templates(*templates)
          @covered_templates_collection&.merge(templates)
        end

        def covered_files
          {}.tap do |coverage_data|
            @covered_templates_collection.map do |template_file|
              coverage_data[template_file] = {template: true}
            end
          end
        end
      end
    end
  end
end
