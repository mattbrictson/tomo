module Tomo::Plugin::Git
  module Helpers
    def git(*args, **opts)
      env(settings[:git_env]) do
        prepend("git") do
          run(*args, **opts)
        end
      end
    end
  end
end
