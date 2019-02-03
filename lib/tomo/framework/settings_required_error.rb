module Tomo
  class Framework
    class SettingsRequiredError < Tomo::Error
      attr_accessor :settings, :task

      def to_console
        <<~ERROR
          The #{yellow(task)} task requires #{settings_sentence}

          Settings can be specified in #{blue(".tomo/project.json")}, or by running tomo
          with the #{blue("-s")} option. For example:

            #{blue("-s #{settings.first}=foo")}

          You can also use environment variables:

            #{blue("TOMO_#{settings.first.upcase}=foo")}
        ERROR
      end

      private

      def settings_sentence
        if settings.length == 1
          return "a value for the #{yellow(settings.first.to_s)} setting."
        end

        sentence = "values for these settings:\n\n  "
        sentence << settings.map { |s| yellow(s.to_s) }.join("\n  ")
      end
    end
  end
end
