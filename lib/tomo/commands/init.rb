module Tomo
  module Commands
    class Init
      extend CLI::Command
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

          This command creates a .tomo/project.rb file relative the current
          directory containing some example configuration.
        BANNER
      end

      def call(*args, _options)
        assert_can_create_tomo_directory!
        assert_no_tomo_project!

        app = args.first || current_dir_name || "default"
        app = app.gsub(/([^\w\-]|_)+/, "_").downcase
        git_url = git_origin_url || "TODO"
        FileUtils.mkdir_p(".tomo/plugins")

        # TODO: use a template for this file
        FileUtils.touch(".tomo/plugins/#{app}.rb")

        IO.write(".tomo/project.rb", project_rb_template(app, git_url))

        Tomo.logger.info(green("✔ Created .tomo/project.rb"))
      end

      private

      def assert_can_create_tomo_directory!
        return if Dir.exist?(".tomo")
        return unless File.exist?(".tomo")

        Tomo.logger.error("Can't create .tomo directory; a file already exists")
        exit(1)
      end

      def assert_no_tomo_project!
        return unless File.exist?(".tomo/project.rb")

        Tomo.logger.error("A .tomo/project.rb file already exists")
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
      end

      def project_rb_template(app, git_url)
        path = File.expand_path("../templates/project.rb", __dir__)
        template = IO.read(path)
        template
          .gsub(/%%APP%%/, app)
          .gsub(/%%GIT_URL%%/, git_url)
      end
    end
  end
end
