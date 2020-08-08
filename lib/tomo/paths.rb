module Tomo
  class Paths
    def initialize(settings)
      @settings = settings
      freeze
    end

    def deploy_to
      path(:deploy_to)
    end

    private

    attr_reader :settings

    def method_missing(method, *args)
      return super unless setting?(method)
      raise ArgumentError, "#{method} takes no arguments" unless args.empty?

      path(:"#{method}_path")
    end

    def respond_to_missing?(method, include_private)
      setting?(method) || super
    end

    def setting?(name)
      settings.key?(:"#{name}_path")
    end

    def path(setting)
      return nil if settings[setting].nil?

      path = settings.fetch(setting).to_s.gsub(%r{//+}, "/")
      Path.new(path)
    end
  end
end
