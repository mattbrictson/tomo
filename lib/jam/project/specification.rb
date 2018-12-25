require "json"

module Jam
  class Project
    class Specification
      def self.from_json(path)
        raise "Jam project (#{path}) not found" unless File.file?(path)

        Jam.logger.debug("Loading project from #{path.inspect}")
        new(JSON.parse(IO.read(path)))
      end

      attr_reader :host, :deploy_tasks, :plugins, :settings

      def initialize(spec)
        @host = Host.new(spec["host"]) if spec.key?("host")
        @environments = merge_environments(spec).freeze
        @deploy_tasks = (spec["deploy"] || []).freeze
        @plugins = (spec["plugins"] || []).freeze
        @settings = (spec["settings"] || {}).freeze
        freeze
      end

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

      def merge_environments(spec)
        environments = spec.delete("environments") || {}
        environments.each_with_object({}) do |(name, env_spec), result|
          merged = spec.merge(env_spec) do |key, orig, new|
            key == "settings" ? orig.merge(new) : new
          end
          result[name] = Specification.new(merged)
        end
      end

      def raise_no_environment_specified
        raise "No environment specified! "\
              "Must be one of #{environments.keys.inspect}"
      end

      def raise_unknown_environment(environment)
        message = "Unknown environment #{environment.inspect}. "
        message << if environments.empty?
                     "This project does not have any environments."
                   else
                     "Must be one of #{environments.keys.inspect}"
                   end
        raise message
      end
    end
  end
end
