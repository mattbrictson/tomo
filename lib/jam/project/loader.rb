module Jam
  class Project
    class Loader
      def self.load!(framework:, json:, tasks_path: nil)
        new(framework, json, tasks_path).call
      end

      def initialize(framework, json, tasks_path)
        @framework = framework
        @json = json
        @tasks_path = tasks_path
      end

      def call
        load_plugins
        load_tasks
        load_settings

        Project.new(framework, json["deploy"].freeze, Host.new(json["host"]))
      end

      private

      attr_reader :framework, :json, :tasks_path

      def load_plugins
        plugin_names = json["plugins"] || []
        plugin_names.unshift("core") unless plugin_names.include?("core")
        plugin_names.each { |name| framework.load_plugin_by_name(name) }
      end

      def load_tasks
        return unless tasks_path && File.file?(tasks_path)

        script = IO.read(tasks_path)
        klass = Class.new(TaskLibrary)
        klass.class_eval(script, tasks_path.to_s, 1)
        framework.register_task_library(nil, klass)
      end

      def load_settings
        framework.assign_settings(json["settings"] || {})
      end
    end
  end
end
