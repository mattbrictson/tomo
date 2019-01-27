module Tomo
  module Commands
    class Version
      def parser
        Tomo::CLI::Parser.new do |parser|
          parser.banner = <<~BANNER
            Usage: tomo version

            Displays tomo's version information.
          BANNER
          parser.permit_empty_args = true
        end
      end

      def call(_options)
        puts "tomo/#{Tomo::VERSION} #{RUBY_DESCRIPTION}"
      end
    end
  end
end
