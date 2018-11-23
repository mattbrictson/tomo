require "forwardable"

module Jam
  class TaskLibrary
    extend Forwardable

    def initialize(framework)
      @framework = framework
    end

    private

    def_delegators :framework, :paths, :remote, :settings
    attr_reader :framework

    def logger
      Jam.logger
    end
  end
end
