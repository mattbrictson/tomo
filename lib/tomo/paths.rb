module Tomo
  class Paths
    def initialize(settings)
      @settings = settings
      freeze
    end

    def release
      path = Runtime::Current.release_path
      return method_missing(:release) if path.nil?

      Path.new(path)
    end

    private

    attr_reader :settings

    def method_missing(method, *args)
      return super unless setting?(method)
      raise ArgumentError, "#{method} takes no arguments" unless args.empty?

      path(method)
    end

    def respond_to_missing?(method, include_private=false)
      setting?(method) || super
    end

    def setting?(name)
      settings.key?(:"#{name}_path")
    end

    def path(name)
      path = settings.fetch(:"#{name}_path").to_s.gsub(%r{//+}, "/")
      Path.new(path)
    end
  end
end
