require "shellwords"

module Tomo::Plugin::Rbenv
  class Tasks < Tomo::TaskLibrary
    def install
      run_installer
      modify_bashrc
      compile_ruby
    end

    private

    def run_installer
      install_url = "https://github.com/rbenv/rbenv-installer/raw/HEAD/bin/rbenv-installer"
      remote.env PATH: raw("$HOME/.rbenv/bin:$HOME/.rbenv/shims:$PATH") do
        remote.run("curl -fsSL #{install_url.shellescape} | bash")
      end
    end

    def modify_bashrc
      existing_rc = remote.capture("cat", paths.bashrc, raise_on_error: false)
      return if existing_rc.include?("rbenv init")

      remote.write(text: <<~BASHRC + existing_rc, to: paths.bashrc)
        if [ -d $HOME/.rbenv ]; then
          export PATH="$HOME/.rbenv/bin:$PATH"
          eval "$(rbenv init -)"
        fi

      BASHRC
    end

    def compile_ruby
      ruby_version = version_setting || extract_ruby_ver_from_version_file

      unless ruby_installed?(ruby_version)
        logger.info("Installing ruby #{ruby_version} -- this may take several minutes")
        remote.run "CFLAGS=-O3 rbenv install #{ruby_version.shellescape} --verbose"
      end
      remote.run "rbenv global #{ruby_version.shellescape}"
    end

    def ruby_installed?(version)
      versions = remote.capture("rbenv versions", raise_on_error: false)
      if versions.match?(/^\*?\s*#{Regexp.quote(version)}\s/)
        logger.info("Ruby #{version} is already installed.")
        return true
      end
      false
    end

    def version_setting
      settings[:rbenv_ruby_version]
    end

    def extract_ruby_ver_from_version_file
      path = paths.release.join(".ruby-version")
      version = remote.capture("cat", path, raise_on_error: false).strip
      return version unless version.empty?

      return RUBY_VERSION if dry_run?

      die <<~REASON
        Could not guess ruby version from .ruby-version file.
        Use the :rbenv_ruby_version setting to specify the version of ruby to install.
      REASON
    end
  end
end
