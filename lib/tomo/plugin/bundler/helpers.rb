# frozen_string_literal: true

module Tomo::Plugin::Bundler
  module Helpers
    def bundle(*args, **opts)
      prepend("bundle") do
        run(*args, **opts, default_chdir: paths.release)
      end
    end

    def bundle?(*args, **opts)
      result = bundle(*args, **opts, raise_on_error: false)
      result.success?
    end
  end
end
