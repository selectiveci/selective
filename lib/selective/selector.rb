module Selective
  module Selector
    class << self
      def tests_from_diff
        request_body = {
          git_branch: default_branch_name,
          sha: current_sha,
          diff: git_diff
        }

        body = Api.request("call_graphs/tests_from_diff", request_body, method: :post)
        body.fetch("tests")
      end

      def default_branch_name
        @default_branch_name ||=
          Api.request("repository", method: :get).fetch("default_branch_name")
      end

      def git_diff_cmd
        "git fetch origin #{default_branch_name} && git diff origin/#{default_branch_name}"
      end

      def git_diff
        `#{git_diff_cmd}`
      end

      def current_sha
        `git rev-parse HEAD`
      end
    end
  end
end
