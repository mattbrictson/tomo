require "erb"

module Tomo
  module TaskAPI
    extend Forwardable

    private

    def_delegators :context, :paths, :settings

    def die(reason)
      Runtime::TaskAbortedError.raise_with(reason, task: context.current_task, host: remote.host)
    end

    def dry_run?
      Tomo.dry_run?
    end

    def logger
      Tomo.logger
    end

    def merge_template(path)
      working_path = paths.tomo_config_file&.dirname
      path = File.expand_path(path, working_path) if working_path && path.start_with?(".")

      Runtime::TemplateNotFoundError.raise_with(path: path) unless File.file?(path)
      template = File.read(path)
      ERB.new(template).result(binding)
    end

    def raw(string)
      ShellBuilder.raw(string)
    end

    def remote
      context.current_remote
    end

    def require_setting(*names)
      missing = names.flatten.select { |sett| settings[sett].nil? }
      return if missing.empty?

      Runtime::SettingsRequiredError.raise_with(settings: missing, task: context.current_task)
    end
    alias require_settings require_setting
  end
end
