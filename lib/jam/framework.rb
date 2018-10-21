require "singleton"

module Jam
  class Framework
    autoload :Current, "jam/framework/current"

    include Singleton

    def initialize
      reset!
    end

    def with_remote(remote, &block)
      current.set(remote: remote, &block)
    end

    def remote
      current[:remote]
    end

    def reset!
      @current = Current.new
    end

    private

    attr_reader :current
  end
end
