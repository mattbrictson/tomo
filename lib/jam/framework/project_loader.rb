require "json"
require "pathname"

module Jam
  class Framework
    class ProjectLoader
      def initialize(plugins_registry:, settings_registry:, tasks_registry:)
        @plugins_registry = plugins_registry
        @settings_registry = settings_registry
        @tasks_registry = tasks_registry
      end

      def load_project(environment=nil)
        dir = Pathname.new(".jam")
        json = load_and_validate_json(dir.join("project.json"))
        json = merge_environment(json, environment)

        load_plugins(json.delete("plugins") || [])
        load_tasks(dir.join("tasks.rb"))
        apply_settings(json.delete("settings") || {})

        json.freeze
      end

      private

      attr_reader :plugins_registry, :settings_registry, :tasks_registry

      def load_and_validate_json(path)
        raise "Jam project (.jam/project.json) not found" unless path.file?

        JSON.parse(IO.read(path))
      end

      def merge_environment(json, env)
        environments = json.delete("environments") || {}
        return json if env.nil? && environments.empty?

        raise_no_environment_specified(environments) if env.nil?
        raise_unknown_environment(environments, env) if environments[env].nil?

        json.merge(environments[env]) do |key, orig, replacement|
          key == "settings" ? orig.merge(replacement) : replacement
        end
      end

      def load_plugins(plugin_names)
        plugin_names.unshift("core") unless plugin_names.include?("core")
        plugin_names.each { |name| plugins_registry.load_plugin_by_name(name) }
      end

      def load_tasks(path)
        return unless path.file?

        script = IO.read(path)
        klass = Class.new
        klass.include(Jam::DSL)
        klass.class_eval(script, path.to_s, 0)
        tasks_registry.register_task_library(nil, klass)
      end

      def apply_settings(settings)
        settings_registry.assign(settings)
      end

      def raise_no_environment_specified(environments)
        raise "No environment specified! "\
              "Must be one of #{environments.keys.inspect}"
      end

      def raise_unknown_environment(environments, env)
        message = "Unknown environment #{env.inspect}. "
        if environments.empty?
          message << "This project does not have any environments."
        else
          message << "Must be one of #{environments.keys.inspect}"
        end
        raise message
      end
    end
  end
end
