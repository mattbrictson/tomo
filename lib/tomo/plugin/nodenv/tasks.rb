require "shellwords"

module Tomo::Plugin::Nodenv
  class Tasks < Tomo::TaskLibrary
    def install
      run_installer
      modify_bashrc
      install_node
      install_yarn
    end

    private

    def run_installer
      install_url = "https://github.com/nodenv/nodenv-installer/raw/HEAD/bin/nodenv-installer"
      remote.env PATH: raw("$HOME/.nodenv/bin:$HOME/.nodenv/shims:$PATH") do
        remote.run("curl -fsSL #{install_url.shellescape} | bash")
      end
    end

    def modify_bashrc
      existing_rc = remote.capture("cat", paths.bashrc, raise_on_error: false)
      return if existing_rc.include?("nodenv init")

      remote.write(text: <<~BASHRC + existing_rc, to: paths.bashrc)
        if [ -d $HOME/.nodenv ]; then
          export PATH="$HOME/.nodenv/bin:$PATH"
          eval "$(nodenv init -)"
        fi
      BASHRC
    end

    def install_node
      require_setting :nodenv_node_version
      node_version = settings[:nodenv_node_version]

      remote.run "nodenv install #{node_version.shellescape}" unless node_installed?(node_version)
      remote.run "nodenv global #{node_version.shellescape}"
    end

    def install_yarn
      version = settings[:nodenv_yarn_version]
      return remote.run "npm i -g yarn@#{version.shellescape}" if version

      logger.info "No :nodenv_yarn_version specified; "\
      "skipping yarn installation."
    end

    def node_installed?(version)
      versions = remote.capture("nodenv versions", raise_on_error: false)
      if versions.include?(version)
        logger.info("Node #{version} is already installed.")
        return true
      end
      false
    end
  end
end
