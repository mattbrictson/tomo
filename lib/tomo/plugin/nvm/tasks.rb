require "shellwords"

module Tomo::Plugin::Nvm
  class Tasks < Tomo::TaskLibrary
    def install
      remote.mkdir_p raw("$HOME/.nvm")
      modify_bashrc
      run_installer
      install_node
      install_yarn
    end

    private

    def run_installer
      require_setting :nvm_version

      nvm_version = settings[:nvm_version]
      install_url = "https://raw.githubusercontent.com/creationix/nvm/"\
                    "v#{nvm_version}/install.sh"
      remote.run("curl -o- #{install_url.shellescape} | bash")
    end

    def modify_bashrc
      existing_rc = remote.capture("cat", paths.bashrc, raise_on_error: false)
      return if existing_rc.include?("nvm.sh")

      remote.write(text: <<~BASHRC + existing_rc, to: paths.bashrc)
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \\. "$NVM_DIR/nvm.sh"

      BASHRC
    end

    def install_node
      require_setting :nvm_node_version
      node_version = settings[:nvm_node_version]

      unless node_installed?(node_version)
        remote.run "nvm", "install", node_version
      end
      remote.run "nvm", "alias", "default", node_version
    end

    def install_yarn
      version = settings[:nvm_yarn_version]
      return remote.run "npm i -g yarn@#{version.shellescape}" if version

      logger.info "No :nvm_yarn_version specified; skipping yarn installation."
    end

    def node_installed?(version)
      versions = remote.capture("nvm ls", raise_on_error: false)
      if versions.include?("v#{version}")
        logger.info("Node #{version} is already installed.")
        return true
      end
      false
    end
  end
end
