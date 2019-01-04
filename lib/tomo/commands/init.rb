module Tomo
  module Commands
    class Init
      include Tomo::Colors

      # rubocop:disable Metrics/MethodLength
      def parser
        Tomo::CLI::Parser.new do |parser|
          parser.banner = <<~BANNER
            Usage: tomo init [APP]

            Sets up a new tomo project named APP. If APP is not specified, the
            name of the current directory will be used.

            This command creates a .tomo/project.json file relative the current
            directory containing some example configuration.
          BANNER
          parser.permit_empty_args = true
          parser.permit_extra_args = true
        end
      end
      # rubocop:enable Metrics/MethodLength

      def call(options)
        assert_can_create_tomo_directory!
        assert_no_tomo_project!

        app = options[:extra_args].first || current_dir_name || "default"
        git_url = git_origin_url || "TODO"
        FileUtils.mkdir(".tomo")
        IO.write(".tomo/project.json", json_template(app, git_url))

        Tomo.logger.info(green("✔ Created .tomo/project.json"))
      end

      private

      def assert_can_create_tomo_directory!
        return if Dir.exist?(".tomo")
        return unless File.exist?(".tomo")

        Tomo.logger.error("Can't create .tomo directory; a file already exists")
        exit(1)
      end

      def assert_no_tomo_project!
        return unless File.exist?(".tomo/project.json")

        Tomo.logger.error("A .tomo/project.json file already exists")
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

      def json_template(app, git_url)
        path = File.expand_path("../templates/project.json", __dir__)
        template = IO.read(path)
        template
          .gsub(/%%APP%%/, app.gsub(/[\W_]+/, "_").downcase)
          .gsub(/%%GIT_URL%%/, git_url)
      end
    end
  end
end
