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
      @finalized = false
      config.enabled_collector_classes.each do |coverage_collector_class|
        coverage_collectors[coverage_collector_class] = coverage_collector_class.new
      end
    end

    def start_recording_code_coverage
      return unless Selective.report_callgraph?

      coverage_collectors.each_value(&:on_start)
    end

    def write_code_coverage_artifact(example_id)
      return unless Selective.report_callgraph?

      cleaned_coverage = {}.tap do |cleaned|
        coverage_collectors.each_value do |coverage_collector|
          coverage_collector.covered_files.each do |covered_file, coverage_data|
            next if Selective.exclude_file?(covered_file)

            cleaned[covered_file] ||= {}
            cleaned[covered_file][coverage_collector.class.name] = coverage_data
          end
        end
      end

      if cleaned_coverage.present?
        map[example_id] = cleaned_coverage
      end

      check_dump_threshold
    end

    def finalize
      return if @finalized
      return unless Selective.report_callgraph?

      if map.any?
        map_storage.dump(map)
      end

      # If by some chance no coverage information
      # has been written, there is nothing to
      # deliver.
      return unless config.coverage_path.exist?

      deliver_payloads(payloads)
      @finalized = true
    end

    def payloads
      coverage_data = Selective::Storage.load(config.coverage_path)
      root = "#{Rails.root}/"

      coverage_data.each_slice(1000).map do |slice|
        data = slice.map { |k, v| [k, v.keys.map { |f| f.sub(root, "") }] }
        call_graph_hash(Hash[data])
      end
    end

    def call_graph_hash(call_graph_data)
      {
        call_graph_data: call_graph_data,
        git_branch: git_branch,
        git_ref: git_ref
      }
    end

    def git_branch
      `git rev-parse --abbrev-ref HEAD`.delete("\n")
    end

    def git_ref
      `git rev-parse HEAD`.delete("\n")
    end

    def deliver_payloads(payloads)
      payloads.each do |payload|
        Selective::Api.request("call_graphs", payload, method: :post)
      end
    end

    def check_dump_threshold
      return unless map.size >= DUMP_THRESHOLD

      map_storage.dump(map)
      @map = {}
    end
  end
end
