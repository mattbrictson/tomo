module Tomo
  module Commands
    class Version < CLI::Command
      include CLI::CommonOptions

      def summary
        "Display tomo’s version"
      end

      def banner
        <<~BANNER
          Usage: #{green('tomo version')}

          Display tomo’s version information.
        BANNER
      end

      def call(_options)
        puts "tomo/#{Tomo::VERSION} #{RUBY_DESCRIPTION}"
      end
    end
  end
end
