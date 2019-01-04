module Tomo::Plugins::Git
  module Helpers
    def git(*args, **opts)
      env(settings[:git_env]) do
        run("git", *args, **opts)
      end
    end
  end
end
