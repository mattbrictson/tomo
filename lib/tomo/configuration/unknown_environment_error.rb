# frozen_string_literal: true

module Tomo
  class Configuration
    class UnknownEnvironmentError < Tomo::Error
      attr_accessor :name, :known_environments, :default_environment

      def to_console
        known_environments.empty? ? no_envs : wrong_envs
      end

      private

      def no_envs
        <<~ERROR
          This project does not have distinct environments.

          Run tomo again without the #{yellow("-e #{name}")} option.
        ERROR
      end

      def wrong_envs
        error = <<~ERROR
          #{yellow(name)} is not a recognized environment for this project.
        ERROR

        if suggestions.any?
          error + suggestions.to_console
        else
          envs = known_environments.map do |env|
            [blue("  #{env}"), env == default_environment ? gray(" (default)") : nil].compact.join
          end
          error + <<~ENVS

            The following environments are available:

            #{envs.join("\n")}
          ENVS
        end
      end

      def suggestions
        @_suggestions ||= Error::Suggestions.new(dictionary: known_environments, word: name)
      end
    end
  end
end
