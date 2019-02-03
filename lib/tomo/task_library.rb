require "forwardable"

module Tomo
  class TaskLibrary
    extend Forwardable

    def self.from_script(path)
      script = IO.read(path)
      klass = Class.new(TaskLibrary)
      klass.class_eval(script, path.to_s, 1)
      klass
    end

    def initialize(framework)
      @framework = framework
    end

    private

    def_delegators :framework, :paths, :settings
    attr_reader :framework

    def die(reason)
      Framework::TaskAbortedError.raise_with(
        reason,
        task: Framework::Current.task,
        host: remote.host
      )
    end

    def dry_run?
      Tomo.dry_run?
    end

    def logger
      Tomo.logger
    end

    def remote
      Framework::Current.remote
    end

    def require_setting(*names)
      missing = names.flatten.select { |sett| settings[sett].nil? }
      return if missing.empty?

      Framework::SettingsRequiredError.raise_with(
        settings: missing,
        task: Framework::Current.task
      )
    end
    alias require_settings require_setting
  end
end
