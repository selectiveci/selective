# frozen_string_literal: true

require "rails/railtie"
require "active_record"

require "selective/version"

require_relative "selective/collectors/ruby_coverage_collector"
require_relative "selective/collectors/active_record/association_collector"
require_relative "selective/collectors/active_record/attribute_reader_collector"
require_relative "selective/collectors/active_record/attribute_writer_collector"
require_relative "selective/collectors/action_view/asset_tag_collector"
require_relative "selective/collectors/action_view/rendered_template_collector"
require_relative "selective/collectors/webpacker/webpacker_app_collector"
require_relative "selective/collectors/sprockets_asset_collector"
require_relative "selective/collector"
require_relative "selective/config"
require_relative "selective/storage"
require_relative "selective/api"

module Selective
  class << self
    attr_accessor :collector
    attr_writer :coverage_collectors

    delegate :coverage_collectors, to: :collector

    def configure
      @config ||= Config.new
      yield @config
    end

    def config
      @config ||= Config.new
    end

    def initialize_collectors
      if enabled?
        @collector = Collector.new(config)

        initialize_rspec_hooks
      end
    end

    def initialize_rspec_hooks
      RSpec.configure do |config|
        config.before(:example) { Selective.collector.start_recording_code_coverage }
        config.after(:example) { |example| Selective.collector.write_code_coverage_artifact(example) }
        config.after(:suite) { Selective.collector.finalize }
      end
    end

    def start_coverage
      if enabled?
        coverage_collectors.values.each do |coverage_collector|
          coverage_collector.on_start
        end
      end
    end

    def enabled?
      config.enable_check.call
    end

    def exclude_file?(file)
      config.file_exclusion_check.call(file)
    end
  end
end
