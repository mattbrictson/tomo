module Tomo
  class Runtime
    class Context
      attr_reader :paths, :settings

      def initialize(settings)
        @paths = Paths.new(settings)
        @settings = settings.freeze
        freeze
      end

      def current_remote
        Current.remote
      end

      def current_task
        Current.task
      end
    end
  end
end
