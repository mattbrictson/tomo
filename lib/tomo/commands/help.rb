module Tomo
  module Commands
    class Help
      def parser
        Tomo::CLI::Parser.new do |parser|
          parser.banner = <<~BANNER
            Usage: tomo help

            Lists tomo's commands.
          BANNER
          parser.permit_empty_args = true
        end
      end

      def call(_options)
        Default.new.parser.usage_and_exit!
      end
    end
  end
end
