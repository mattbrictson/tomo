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
        app = app.gsub(/([^\w\-]|_)+/, "_").downcase
        FileUtils.mkdir_p(".tomo/plugins")

        # TODO: use a template for this file
        FileUtils.touch(".tomo/plugins/#{app}.rb")

        IO.write(DEFAULT_CONFIG_PATH, config_rb_template(app))

        logger.info(green("✔ Created #{DEFAULT_CONFIG_PATH}"))
      end

      private

      def assert_can_create_tomo_directory!
        return if Dir.exist?(".tomo")
        return unless File.exist?(".tomo")

        logger.error("Can't create .tomo directory; a file already exists")
        exit(1)
      end

      def assert_no_tomo_project!
        return unless File.exist?(DEFAULT_CONFIG_PATH)

        logger.error("A #{DEFAULT_CONFIG_PATH} file already exists")
        exit(1)
      end

      def current_dir_name
        File.basename(File.expand_path("."))
      end

      def git_origin_url
        return unless File.file?(".git/config")
        return unless `git remote -v` =~ /^origin/

        url = `git remote get-url origin`.chomp
        url.empty? ? nil : url
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

      # rubocop:disable Metrics/AbcSize
      def config_rb_template(app)
        path = File.expand_path("../templates/config.rb", __dir__)
        template = IO.read(path)
        template
          .gsub(/%%APP%%/, app)
          .gsub(/%%GIT_URL%%/, git_origin_url&.inspect || "nil # FIXME")
          .gsub(/%%RUBY_VERSION%%/, RUBY_VERSION.inspect)
          .gsub(/%%NODE_VERSION%%/, node_version&.inspect || "nil # FIXME")
          .gsub(/%%YARN_VERSION%%/, yarn_version.inspect)
      end
      # rubocop:enable Metrics/AbcSize
    end
  end
end
