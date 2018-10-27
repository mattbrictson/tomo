require "pathname"

module Jam
  class Paths
    def initialize(settings)
      @settings = settings
      freeze
    end

    private

    attr_reader :settings

    def method_missing(method, *args)
      return super unless setting?(method)
      raise ArgumentError, "#{method} takes no arguments" unless args.empty?

      pathname(method)
    end

    def respond_to_missing?(method, include_private=false)
      setting?(method) || super
    end

    def setting?(name)
      settings.key?(:"#{name}_path")
    end

    def pathname(name)
      path = settings.fetch(:"#{name}_path").to_s.gsub(%r{//+}, "/")
      Pathname.new(path)
    end
  end
end
