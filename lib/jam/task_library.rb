require "forwardable"

module Jam
  class TaskLibrary
    extend Forwardable

    def initialize(framework)
      @framework = framework
    end

    private

    def_delegators :framework, :logger, :paths, :remote, :settings
    attr_reader :framework
  end
end
