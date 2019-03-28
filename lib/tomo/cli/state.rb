module Tomo
  class CLI
    class State
      attr_reader :args, :options, :processed_rules

      def initialize
        @args = []
        @options = Options.new
        @processed_rules = []
      end

      def parsed_arg(arg)
        args << arg
      end

      def parsed_option(key, value)
        options.all(key) << value
      end

      def processed_rule(rule)
        @processed_rules |= [rule]
      end

      def processed?(rule)
        @processed_rules.include?(rule)
      end
    end
  end
end
