require "forwardable"

module Tomo
  class CLI
    class Parser
      extend Forwardable
      include Colors

      def_delegators :usage, :banner=, :to_s

      attr_accessor :context

      def initialize
        @rules = Rules.new
        @usage = Usage.new
        @after_parse_methods = []
      end

      def arg(spec, values: [])
        rules.add_arg(spec, proc_for(values))
      end

      def option(key, spec, desc=nil, values: [], &block)
        rules.add_option(key, spec, proc_for(values), &block)
        usage.add_option(spec, desc)
      end

      def after_parse(context_method_name)
        after_parse_methods << context_method_name
      end

      def parse(argv)
        state = State.new

        options_argv, literal_argv = split(argv, "--")
        evaluate(options_argv, state, literal: false)
        evaluate(literal_argv, state, literal: true)
        check_required_rules(state)
        invoke_after_parse_methods(state)

        [*state.args, state.options]
      end

      private

      attr_reader :rules, :usage, :after_parse_methods

      def evaluate(argv, state, literal:)
        RulesEvaluator.evaluate(rules: rules.to_a, argv: argv, state: state, literal: literal)
      end

      def check_required_rules(state)
        (rules.to_a - state.processed_rules).each do |rule|
          next unless rule.required?

          type = rule.is_a?(Rules::Argument) ? "" : " option"
          raise CLI::Error, "Please specify the #{yellow(rule.to_s)}#{type}."
        end
      end

      def invoke_after_parse_methods(state)
        after_parse_methods.each do |method|
          context.send(method, *state.args, state.options)
        end
      end

      def proc_for(values)
        return values if values.respond_to?(:call)
        return proc { values } unless values.is_a?(Symbol)

        method = values
        proc { |*args| context.send(method, *args) }
      end

      def split(argv, delimiter)
        index = argv.index(delimiter)
        return [argv, []] if index.nil?
        return [argv, []] if index == argv.length - 1 && Completions.active?

        before = argv[0...index]
        after = argv[(index + 1)..]

        [before, after]
      end
    end
  end
end
