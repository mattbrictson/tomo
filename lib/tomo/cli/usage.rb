module Tomo
  class CLI
    class Usage
      def initialize
        @options = []
        @banner_proc = proc { "" }
      end

      def add_option(spec, desc)
        options << [
          spec.start_with?("--") ? "    #{spec}" : spec,
          desc
        ]
      end

      def banner=(banner)
        @banner_proc = banner.respond_to?(:call) ? banner : proc { banner }
      end

      def to_s
        indent(["", banner_proc.call, "Options:", "", indent(options_help), "\n"].join("\n"))
      end

      private

      attr_reader :banner_proc, :options

      def options_help
        width = options.map { |opt| opt.first.length }.max
        options.each_with_object([]) do |(spec, desc), help|
          help << "#{Colors.yellow(spec.ljust(width))}    #{desc}"
        end.join("\n")
      end

      def indent(str)
        str.gsub(/^/, "  ")
      end
    end
  end
end
