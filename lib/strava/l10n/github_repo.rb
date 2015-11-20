require 'config/key_manager'
require 'strava/l10n/github_api'
require 'strava/l10n/transifex_project'
require 'strava/l10n/tx_config'

module Strava
  module L10n
    class GitHubRepo

      def initialize(name)
        @name = name
        @config = Strava::Config::KeyManager.github_repo_config(name)
      end

      def name
        @name
      end

      def pr_title
        @config['pr_title'] != nil ? @config['pr_title'] : "Transifex - New/Updated translations"
      end

      def pr_body
        @config['pr_body'] != nil ? @config['pr_body'] : "Translation updates"
      end

      def pr_assignee
        @config['pr_assignee']
      end

      def commit_message
        @config['commit_message'] != nil ? @config['commit_message'] : "Transifex Integration - Updating translations for #{path}"
      end

      def push_to_master
        (@config['push_to_master'] != nil) ? @config['push_to_master'] : true
      end

      def push_branch_prefix
        @config['push_branch_prefix'] != nil ? @config['push_branch_prefix'] : "transifex-integration"
      end

      def push_to_branch
        (['false', false].include? push_to_master) ? "#{push_branch_prefix}-#{Time.now.to_i}" : "master"
      end

      def transifex_project
        @transifex_project = @transifex_project ||
            Strava::L10n::TransifexProject.new(@config['push_source_to'])
      end

      def api
        @api = @api || Strava::L10n::GitHubApi.new(
            @config['api_username'], @config['api_token'])
      end

    end
  end
end
