module Jam
  module Plugins
    class Core
      module Helpers
        def capture(*command, **run_opts)
          result = run(*command, **{ silent: true }.merge(run_opts))
          result.stdout
        end

        def run?(*command, **run_opts)
          result = run(*command, **run_opts.merge(raise_on_error: false))
          result.success?
        end

        def ln_sf(target, link, **run_opts)
          run("ln", "-sf", target, link, **run_opts)
        end

        def mkdir_p(directory, **run_opts)
          run("mkdir", "-p", directory, **run_opts)
        end

        def rm_rf(path, **run_opts)
          run("rm", "-rf", path, **run_opts)
        end

        def command_available?(command_name, **run_opts)
          run?("which", command_name, **{ silent: true }.merge(run_opts))
        end

        def executable?(file, **run_opts)
          flag?("-x", file, **run_opts)
        end

        def directory?(directory, **run_opts)
          flag?("-d", directory, **run_opts)
        end

        private

        def flag?(flag, path, **run_opts)
          run?("[ #{flag} #{path.shellescape} ]", **run_opts)
        end
      end
    end
  end
end
