module Tomo
  class Runtime
    class SettingsRequiredError < Tomo::Error
      attr_accessor :command_name, :settings, :task

      def to_console
        <<~ERROR
          The #{yellow(task)} task requires #{settings_sentence}

          Settings can be specified in #{blue(DEFAULT_CONFIG_PATH)}, or by running tomo
          with the #{blue('-s')} option. For example:

            #{blue("tomo -s #{settings.first}=foo")}

          You can also use environment variables:

            #{blue("TOMO_#{settings.first.upcase}=foo tomo #{command_name}")}
        ERROR
      end

      private

      def settings_sentence
        return "a value for the #{yellow(settings.first.to_s)} setting." if settings.length == 1

        sentence = "values for these settings:\n\n  "
        sentence << settings.map { |s| yellow(s.to_s) }.join("\n  ")
      end
    end
  end
end
