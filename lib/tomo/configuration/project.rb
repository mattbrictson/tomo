require "json"

module Tomo
  class Configuration
    class Project
      def self.from_json(path)
        ProjectNotFoundError.raise_with(path: path) unless File.file?(path)

        Tomo.logger.debug("Loading project from #{path.inspect}")
        new(JSON.parse(IO.read(path)), path)
      end

      attr_reader :hosts, :deploy_tasks, :plugins, :roles, :settings,
                  :source_path

      # rubocop:disable Metrics/AbcSize
      def initialize(data, source_path=nil)
        normalize_hosts(data)
        @source_path = source_path
        @hosts = (data["hosts"] || []).map(&Host.method(:parse)).freeze
        @environments = merge_environments(data).freeze
        @deploy_tasks = (data["deploy"] || []).freeze
        @plugins = (data["plugins"] || []).freeze
        @roles = data["roles"].freeze
        @settings = (data["settings"] || {}).freeze
        freeze
      end
      # rubocop:enable Metrics/AbcSize

      def for_environment(env)
        if env.nil?
          raise_no_environment_specified unless environments.empty?
          self
        else
          environments.fetch(env) do
            raise_unknown_environment(env)
          end
        end
      end

      def environment_names
        environments.keys
      end

      def task_library_path
        return nil if source_path.nil?

        File.expand_path("../tasks.rb", source_path)
      end

      private

      attr_reader :environments

      def normalize_hosts(data)
        return unless data.key?("host")
        raise "Cannot specify both host and hosts" if data.key?("hosts")

        data["hosts"] = [data.delete("host")]
      end

      def merge_environments(data)
        environments = data.delete("environments") || {}
        environments.each_with_object({}) do |(name, env_data), result|
          normalize_hosts(env_data)
          merged = data.merge(env_data) do |key, orig, new|
            key == "settings" ? orig.merge(new) : new
          end
          result[name] = Project.new(merged, source_path)
        end
      end

      def raise_no_environment_specified
        UnspecifiedEnvironmentError.raise_with(environments: environments.keys)
      end

      def raise_unknown_environment(environment)
        UnknownEnvironmentError.raise_with(
          name: environment,
          known_environments: environments.keys
        )
      end
    end
  end
end
