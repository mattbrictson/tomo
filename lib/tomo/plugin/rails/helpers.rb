module Tomo::Plugin::Rails
  module Helpers
    def rails(*args, **opts)
      prepend("exec", "rails") do
        bundle(*args, **opts)
      end
    end

    def rake(*args, **opts)
      prepend("exec", "rake") do
        bundle(*args, **opts)
      end
    end

    def rake?(*args, **opts)
      result = rake(*args, **opts.merge(raise_on_error: false))
      result.success?
    end

    def thor(*args, **opts)
      prepend("exec", "thor") do
        bundle(*args, **opts)
      end
    end
  end
end
