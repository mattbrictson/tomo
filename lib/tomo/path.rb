require "delegate"
require "pathname"

module Tomo
  class Path < SimpleDelegator
    def initialize(path)
      super(path.to_s)
      freeze
    end

    def join(*other)
      self.class.new(Pathname.new(self).join(*other))
    end

    def dirname
      self.class.new(Pathname.new(self).dirname)
    end
  end
end
