module Tomo::Plugin::Bundler
  module Helpers
    def bundle(*args, **opts)
      prepend("bundle") do
        run(*args, **opts.merge(default_chdir: paths.release))
      end
    end

    def bundle?(*args, **opts)
      result = bundle(*args, **opts.merge(raise_on_error: false))
      result.success?
    end
  end
end
