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
      install_url = "https://github.com/rbenv/rbenv-installer/raw/master/bin/rbenv-installer"
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
      require_setting :rbenv_ruby_version
      ruby_version = settings[:rbenv_ruby_version]

      unless ruby_installed?(ruby_version)
        remote.run "CFLAGS=-O3 rbenv install #{ruby_version.shellescape}"
      end
      remote.run "rbenv global #{ruby_version.shellescape}"
    end

    def ruby_installed?(version)
      if remote.capture("rbenv versions").include?(version)
        logger.info("Ruby #{version} is already installed.")
        return true
      end
      false
    end
  end
end
