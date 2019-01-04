module Tomo::Plugins::Rails
  module Helpers
    def rails(*args, **opts)
      bundle("exec", "rails", *args, **opts)
    end

    def rake(*args, **opts)
      bundle("exec", "rake", *args, **opts)
    end
  end
end
