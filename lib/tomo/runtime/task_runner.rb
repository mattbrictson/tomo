module Tomo
  class Runtime
    class TaskRunner
      extend Forwardable

      def_delegators :@context, :paths, :settings
      attr_reader :context

      def initialize(helper_modules:, settings:, tasks_registry:)
        @helper_modules = helper_modules.freeze
        @context = Context.new(settings.freeze)
        @tasks_by_name = tasks_registry.bind_tasks(context).freeze
        freeze
      end

      def validate_task!(name)
        return if tasks_by_name.key?(name)

        UnknownTaskError.raise_with(
          name,
          unknown_task: name,
          known_tasks: tasks_by_name.keys
        )
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
          conn = SSH.connect(host: host, options: SSH::Options.new(settings))
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
    end
  end
end
