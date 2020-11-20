module Selective
  module Selector
    class << self
      def tests_from_diff
        request_body = {
          git_branch: default_branch_name,
          sha: current_sha,
          diff: git_diff
        }

        body = Selective::Api.request("call_graphs/tests_from_diff", request_body, method: :post)
        body["tests"]
      rescue
        # TODO: display error
        []
      end

      def default_branch_name
        @default_branch_name ||= begin
          body = Selective::Api.request("repository", method: :get)
          body["default_branch_name"]
        end
      rescue
        @default_branch_name = nil
      end

      def git_diff
        `git fetch origin #{default_branch_name}`
        `git diff origin/#{default_branch_name}`
      end

      def current_sha
        `git rev-parse HEAD`
      end
    end
  end
end
