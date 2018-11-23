require "forwardable"

module Jam
  class CLI
    class Command
      extend Forwardable
      include Jam::Colors

      def initialize(framework)
        @jam = framework
      end

      private

      def_delegators :jam,
                     :connect, :invoke_task, :load!,
                     :project, :settings, :tasks

      attr_reader :jam

      def logger
        Jam.logger
      end
    end
  end
end
