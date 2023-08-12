require "erb"
require "fileutils"

module Tomo
  module Commands
    class Init < CLI::Command
      include CLI::CommonOptions

      arg "[APP]"

      def summary
        "Start a new tomo project with a sample config"
      end

      def banner
        <<~BANNER
          Usage: #{green('tomo init')} #{yellow('[APP]')}

          Set up a new tomo project named #{yellow('APP')}. If #{yellow('APP')} is not specified, the
          name of the current directory will be used.

          This command creates a #{DEFAULT_CONFIG_PATH} file relative the current
          directory containing some example configuration.
        BANNER
      end

      def call(*args, _options)
        assert_can_create_tomo_directory!
        assert_no_tomo_project!

        app = args.first || current_dir_name || "default"
        app = app.gsub(/([^\w-]|_)+/, "_").downcase

        FileUtils.mkdir_p(".tomo/plugins")
        File.write(".tomo/plugins/#{app}.rb", plugin_rb_template)
        File.write(DEFAULT_CONFIG_PATH, config_rb_template(app))

        logger.info(green("✔ Created #{DEFAULT_CONFIG_PATH}"))
      end

      private

      def assert_can_create_tomo_directory!
        return if Dir.exist?(".tomo")
        return unless File.exist?(".tomo")

        logger.error("Can't create .tomo directory; a file already exists")
        CLI.exit(1)
      end

      def assert_no_tomo_project!
        return unless File.exist?(DEFAULT_CONFIG_PATH)

        logger.error("A #{DEFAULT_CONFIG_PATH} file already exists")
        CLI.exit(1)
      end

      def current_dir_name
        File.basename(File.expand_path("."))
      end

      def git_origin_url
        return unless File.file?(".git/config")
        return unless `git remote -v`.match?(/^origin/)

        url = `git remote get-url origin`.chomp
        url.empty? ? nil : url
      rescue SystemCallError
        nil
      end

      def git_main_branch
        return unless File.file?(".git/config")

        # If "main" or "master" is in the list of branch names, use that
        branch = (%w[main master] & `git branch`.scan(/^\W*(.+)$/).flatten).first

        # If not, use the current branch
        if branch.nil?
          branch = if `git --version`[/\d+\.\d+/].to_f >= 2.22
                     `git branch --show-current`.chomp
                   else
                     `git rev-parse --abbrev-ref HEAD`.chomp
                   end
        end

        branch.empty? ? nil : branch
      rescue SystemCallError
        nil
      end

      def node_version
        `node --version`.chomp.sub(/^v/i, "")
      rescue SystemCallError
        nil
      end

      def yarn_version
        `yarn --version`.chomp
      rescue SystemCallError
        nil
      end

      def rubocop?
        File.exist?(".rubocop.yml")
      end

      # Does a .ruby-version file exist match the executing RUBY_VERSION?
      def using_ruby_version_file?
        return false unless File.exist?(".ruby-version")

        File.read(".ruby-version").rstrip == RUBY_VERSION
      rescue IOError
        false
      end

      # Does a .node-version file exist match `node --version`?
      def using_node_version_file?
        return false unless File.exist?(".node-version")

        version = File.read(".node-version").rstrip
        !version.empty? && version == node_version
      rescue IOError
        false
      end

      def config_rb_template(app)
        path = File.expand_path("../templates/config.rb.erb", __dir__)
        template = File.read(path)
        ERB.new(template, trim_mode: "-").result(binding)
      end

      def plugin_rb_template
        path = File.expand_path("../templates/plugin.rb.erb", __dir__)
        template = File.read(path)
        ERB.new(template, trim_mode: "-").result(binding)
      end
    end
  end
end
