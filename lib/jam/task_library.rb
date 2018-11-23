require "forwardable"

module Jam
  class TaskLibrary
    extend Forwardable

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
      Current.remote
    end
  end
end
