module Jam::Plugins::Bundler
  class Tasks < Jam::TaskLibrary
    def install
      return if remote.bundle?("check", *check_options)

      remote.bundle("install", *install_options)
    end

    def clean
      remote.bundle("clean", settings[:bundler_clean_options])
    end

    def upgrade_bundler
      needed_bundler_ver = extract_bundler_ver_from_lockfile
      return if needed_bundler_ver.nil?

      remote.run(
        "gem install bundler",
        "--conservative --no-document",
        "-v #{needed_bundler_ver}"
      )
    end

    private

    def check_options
      gemfile = settings[:bundler_gemfile]
      path = paths.bundler

      options = []
      options.append("--gemfile", gemfile) if gemfile
      options.append("--path", path) if path
      options
    end

    # rubocop:disable Metrics/AbcSize
    def install_options
      binstubs = settings[:bundler_binstubs]
      jobs = settings[:bundler_jobs]
      without = settings[:bundler_without]
      flags = settings[:bundler_flags]

      options = check_options.dup
      options.append("--binstubs", binstubs) if binstubs
      options.append("--jobs", jobs) if jobs
      options.append("--without", without) if without
      options.append(flags) if flags

      options
    end
    # rubocop:enable Metrics/AbcSize

    def extract_bundler_ver_from_lockfile
      lockfile_tail = remote.capture(
        "tail -n 10",
        paths.release.join("Gemfile.lock"),
        raise_on_error: false
      )
      lockfile_tail[/BUNDLED WITH\n   (\S+)$/, 1]
    end
  end
end
