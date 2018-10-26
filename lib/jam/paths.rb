require "pathname"

module Jam
  class Paths
    def initialize(settings)
      @settings = settings
      freeze
    end

    def current
      pathname("current")
    end

    def release
      pathname("release")
    end

    def repo
      pathname("repo")
    end

    def shared
      pathname("shared")
    end

    private

    attr_reader :settings

    def pathname(name)
      Pathname.new(settings.fetch(:"#{name}_path"))
    end
  end
end
