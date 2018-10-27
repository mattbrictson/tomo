require "pathname"

module Jam
  class Path
    def initialize(path)
      @path = path.to_s
      freeze
    end

    def join(*other)
      Path.new(Pathname.new(path).join(*other).to_s)
    end

    def to_s
      path
    end

    private

    attr_reader :path
  end
end
