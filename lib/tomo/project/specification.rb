require "json"

module Tomo
  class Project
    class Specification
      def self.from_json(path)
        NotFoundError.raise_with(path: path) unless File.file?(path)

        Tomo.logger.debug("Loading project from #{path.inspect}")
        new(JSON.parse(IO.read(path)))
      end

      attr_reader :hosts, :deploy_tasks, :plugins, :roles, :settings

      # rubocop:disable Metrics/AbcSize
      def initialize(spec)
        normalize_hosts(spec)
        @hosts = build_hosts(spec["hosts"])
        @environments = merge_environments(spec).freeze
        @deploy_tasks = (spec["deploy"] || []).freeze
        @plugins = (spec["plugins"] || []).freeze
        @roles = Framework::RolesFilter.new(spec["roles"])
        @settings = (spec["settings"] || {}).freeze
        freeze
      end
      # rubocop:enable Metrics/AbcSize

      def for_environment(env)
        if env.nil?
          raise_no_environment_specified unless environments.empty?
          self
        elsif env == :auto
          environments.values.first || self
        else
          environments.fetch(env) do
            raise_unknown_environment(env)
          end
        end
      end

      private

      attr_reader :environments

      # rubocop:disable Metrics/MethodLength
      def normalize_hosts(spec)
        return unless spec.key?("host")
        raise "Cannot specify both host and hosts" if spec.key?("hosts")

        host = Host.parse(spec.delete("host"))
        spec["hosts"] = {
          nil => {
            "address" => host.address,
            "port" => host.port,
            "roles" => host.roles,
            "user" => host.user
          }
        }
      end
      # rubocop:enable Metrics/MethodLength

      def build_hosts(spec_hosts)
        (spec_hosts || []).map do |name, meta|
          Host.new(
            name: name,
            address: meta["address"],
            port: meta["port"],
            roles: meta["roles"],
            user: meta["user"]
          )
        end
      end

      def merge_environments(spec)
        environments = spec.delete("environments") || {}
        environments.each_with_object({}) do |(name, env_spec), result|
          normalize_hosts(env_spec)
          merged = spec.merge(env_spec) do |key, orig, new|
            key == "settings" ? orig.merge(new) : new
          end
          result[name] = Specification.new(merged)
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
