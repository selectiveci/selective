module Selective
  class Collector
    attr_accessor :coverage_collectors, :config, :map_storage, :map

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
      if Selective.enabled?
        coverage_collectors.each do |coverage_collector_class, coverage_collector|
          coverage_collector.on_start
        end
      end
    end

    def write_code_coverage_artifact(example)
      if Selective.enabled?
        cleaned_coverage = {}.tap do |cleaned|
          coverage_collectors.values.each do |coverage_collector|
            coverage_collector.covered_files.each do |covered_file, coverage_data|
              next if Selective.exclude_file?(covered_file)
              cleaned[covered_file] ||= {}
              cleaned[covered_file][coverage_collector.class.name] = coverage_data
            end
          end
        end

        map[example.id] = cleaned_coverage
        check_dump_threshold
      end
    end

    def finalize(suite)
      return if map.nil?
      map_storage.dump(map) if map.size.positive?
      data = Selective::Storage.load(config.coverage_path)
      call_graph_data = Hash[data.map { |k, v| [k, v.keys.map { |f| f.sub("#{Rails.root}/", "") }] }]
      git_branch = `git rev-parse --abbrev-ref HEAD`.delete("\n")
      git_ref = `git rev-parse HEAD`.delete("\n")

      uri = URI.parse("http://host.docker.internal:3000/api/v1/call_graphs")
      headers = {:'Content-Type' => "application/json", "X-API-KEY" => config.api_key}
      request_body = {
        call_graph_data: call_graph_data,
        git_branch: git_branch,
        git_ref: git_ref
      }

      # Create the HTTP objects
      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Post.new(uri.request_uri, headers)
      request.body = request_body.to_json

      # Send the request
      http.request(request)
    end

    def dump_threshold
      10
    end

    def check_dump_threshold
      return unless dump_threshold.positive? && map.size >= dump_threshold

      map_storage.dump(map)
      @map = {}
    end
  end
end
