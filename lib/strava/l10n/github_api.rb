require 'octokit'

module Strava
  module L10n
    class GitHubApi

      def initialize(login, oauth_token)
        @client = Octokit::Client.new(login: login, oauth_token: oauth_token)
      end

      def tags(repo)
        @client.tags(repo)
      end

      def tree(repo, sha)
        @client.tree(repo, sha, recursive: 1)
      end

      def blob(repo, sha)
        @client.blob(repo, sha)
      end

      def create_fetch_branch(repo, config_options, master)
        if config_options[:branch_slug] != 'master'
          @client.create_ref repo, "heads/#{config_options[:branch_slug]}", master[:object][:sha]
        else
          master
        end
      end

      def assign_pull_request(repo, config_options, pr)
        # Assign PR to user
        if config_options[:assignee] != nil || pr['number'] != nil
          @client.update_issue(repo,
            pr['number'],
            config_options[:pr_title],
            config_options[:pr_body],
            :assignee => config_options[:assignee]
          )
        else
          raise ArgumentError.new(
            config_options[:assignee] == nil ? "invalid value assignee: \"#{self}\"" : "invalid PR: \"#{self}\""
          )
        end
      end

      def create_pull_request(repo, config_options)
        # Create a PR
        @client.create_pull_request(
          repo,
          "master",
          config_options[:branch_slug],
          config_options[:pr_title],
          config_options[:pr_body]
        )
      end

      def commit(repo, path, content, config_options = {})
        blob = @client.create_blob repo, content
        master = @client.ref repo, 'heads/master'
        # Create new branch if not already exist
        branch = create_fetch_branch(repo, config_options, master)
        base_commit = @client.commit repo, branch[:object][:sha]
        tree = @client.create_tree repo,
                                   [{ path: path, mode: '100644', type: 'blob', sha: blob }],
                                   options = {base_tree: base_commit[:commit][:tree][:sha]}
        commit = @client.create_commit repo, config_options[:commit_message], tree[:sha],
                                       parents=branch[:object][:sha]
        @client.update_ref repo, "heads/#{config_options[:branch_slug]}", commit[:sha]
        if config_options[:branch_slug] != 'master'
          pr = create_pull_request(repo, config_options)
          assign_pull_request(repo, config_options, pr)
        end
      end

      def get_commit(repo, sha)
        @client.commit(repo, sha)
      end

    end
  end
end
