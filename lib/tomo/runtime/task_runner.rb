module Tomo
  class Runtime
    class TaskRunner
      extend Forwardable

      def_delegators :@context, :paths, :settings
      attr_reader :context

      def initialize(plugins_registry:, settings:)
        interpolated_settings = SettingsInterpolation.interpolate(
          plugins_registry.settings.merge(settings)
        )
        @helper_modules = plugins_registry.helper_modules.freeze
        @context = Context.new(interpolated_settings)
        @tasks_by_name = plugins_registry.bind_tasks(context).freeze
        freeze
      end

      def validate_task!(name)
        return if tasks_by_name.key?(name)

        UnknownTaskError.raise_with(name, unknown_task: name, known_tasks: tasks_by_name.keys)
      end

      def run(task:, remote:)
        validate_task!(task)
        Current.with(task: task, remote: remote) do
          Tomo.logger.task_start(task)
          tasks_by_name[task].call
        end
      end

      def connect(host)
        Current.with(host: host) do
          conn = SSH.connect(host: host, options: ssh_options)
          remote = Remote.new(conn, context, helper_modules)
          return remote unless block_given?

          begin
            return yield(remote)
          ensure
            remote&.close if block_given?
          end
        end
      end

      private

      attr_reader :helper_modules, :tasks_by_name

      def ssh_options
        settings.slice(*SSH::Options::DEFAULTS.keys)
      end
    end
  end
end
