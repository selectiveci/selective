# frozen_string_literal: true

module Selective
  module Collectors
    module ActionView
      class RenderedTemplateCollector
        class << self
          attr_reader :subscriber

          def subscribe(collector)
            @subscriber ||= ActiveSupport::Notifications.subscribe("!render_template.action_view") { |_name, _start, _finish, _id, payload|
              collector.add_covered_templates(payload.fetch(:identifier))
            }
          end

          def unsubscribe
            if subscriber
              ActiveSupport::Notifications.unsubscribe(subscriber)
              @subscriber = nil
            end
          end
        end

        def initialize
          self.class.subscribe(self) unless self.class.subscriber
        end

        def on_start
          @covered_templates_collection = Set.new
        end

        def add_covered_templates(*templates)
          on_start unless covered_templates_collection

          covered_templates_collection.merge(templates)
        end

        def covered_files
          {}.tap do |coverage_data|
            covered_templates_collection.map do |template_file|
              coverage_data[template_file] = {template: true}
            end

            on_start
          end
        end

        private

        attr_reader :covered_templates_collection
      end
    end
  end
end
