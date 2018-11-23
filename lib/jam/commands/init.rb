module Jam
  module Commands
    class Init
      include Jam::Colors

      # rubocop:disable Metrics/MethodLength
      def parser
        Jam::CLI::Parser.new do |parser|
          parser.banner = <<~BANNER
            Usage: jam init [APP]

            Sets up a new jam project named APP. If APP is not specified, the
            name of the current directory will be used.

            This command creates a .jam/project.json file relative the current
            directory containing some example configuration.
          BANNER
          parser.permit_empty_args = true
          parser.permit_extra_args = true
        end
      end
      # rubocop:enable Metrics/MethodLength

      def call(options)
        assert_no_jam_dir!

        app = options[:extra_args].first || current_dir_name || "default"
        git_url = git_origin_url || "TODO"
        FileUtils.mkdir(".jam")
        IO.write(".jam/project.json", json_template(app, git_url))

        Jam.logger.info(green("✔ Created .jam/project.json"))
      end

      private

      def assert_no_jam_dir!
        return unless File.exist?(".jam")

        if Dir.exist?(".jam")
          Jam.logger.error("A .jam directory already exists")
        else
          Jam.logger.error("Can't create .jam directory; a file already exists")
        end

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
