module Jam
  module Plugin
    def self.extended(mod)
      mod.instance_variable_set(:@helper_modules, [])
      mod.instance_variable_set(:@default_settings, {})
    end

    attr_reader :helper_modules, :default_settings

    def helpers(mod, *more_mods)
      @helper_modules.append(mod, *more_mods)
    end

    def defaults(settings)
      @default_settings.merge!(settings)
    end
  end
end
