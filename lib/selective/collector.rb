module Selective
  class Collector
    attr_accessor :coverage_collectors, :config, :map_storage, :map

    DUMP_THRESHOLD = 10

    def initialize(config)
      @config = config
      @coverage_collectors = {}
      @map_storage = Selective::Storage.new(config.coverage_path)
      @map_storage.clear!
      @map = {}
      config.enabled_collector_classes.each do |coverage_collector_class|
        coverage_collectors[coverage_collector_class] = coverage_collector_class.new
      end
    end

    def start_recording_code_coverage
      return unless Selective.enabled?

      coverage_collectors.each do |_coverage_collector_class, coverage_collector|
        coverage_collector.on_start
      end
    end

    def write_code_coverage_artifact(example)
      return unless Selective.enabled?

      cleaned_coverage = {}.tap do |cleaned|
        coverage_collectors.values.each do |coverage_collector|
          coverage_collector.covered_files.each do |covered_file, coverage_data|
            next if Selective.exclude_file?(covered_file)
            cleaned[covered_file] ||= {}
            cleaned[covered_file][coverage_collector.class.name] = coverage_data
          end
        end
      end

      map[example.id] = cleaned_coverage if cleaned_coverage.present?
      check_dump_threshold
    end

    def finalize
      return unless Selective.enabled?

      map_storage.dump(map) if map.size.positive?

      # If by some chance no coverage information
      # has been written, there is nothing to
      # deliver.
      return unless config.coverage_path.exist?

      deliver_payload(payload)
    end

    def payload
      data = Selective::Storage.load(config.coverage_path)
      call_graph_data = Hash[data.map { |k, v| [k, v.keys.map { |f| f.sub("#{Rails.root}/", "") }] }]
      git_branch = `git rev-parse --abbrev-ref HEAD`.delete("\n")
      git_ref = `git rev-parse HEAD`.delete("\n")

      {
        call_graph_data: call_graph_data,
        git_branch: git_branch,
        git_ref: git_ref
      }
    end

    def deliver_payload(payload)
      Selective::Api.request("call_graphs", payload, method: :post)
    end

    def check_dump_threshold
      return unless map.size >= DUMP_THRESHOLD

      map_storage.dump(map)
      @map = {}
    end
  end
end
