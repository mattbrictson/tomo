raise "The testing plugin cannot be used outside of unit tests" unless defined?(Tomo::Testing)

module Tomo::Plugin
  class Testing < Tomo::TaskLibrary
    extend Tomo::PluginDSL
    tasks self

    def call_helper
      helper, args, kwargs = settings[:run_args]
      value = remote.public_send(helper, *args, **(kwargs || {}))
      remote.host.helper_values << value
    end
  end
end
