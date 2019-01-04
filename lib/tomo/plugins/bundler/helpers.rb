module Tomo::Plugins::Bundler
  module Helpers
    def bundle(*args, **opts)
      env(settings[:bundler_env_variables]) do
        run("bundle", *args, **opts.merge(default_chdir: paths.release))
      end
    end

    def bundle?(*args, **opts)
      result = bundle(*args, **opts.merge(raise_on_error: false))
      result.success?
    end
  end
end
