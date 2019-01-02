require "forwardable"

module Jam
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

    def logger
      Jam.logger
    end

    def remote
      Framework::Current.remote
    end
  end
end
