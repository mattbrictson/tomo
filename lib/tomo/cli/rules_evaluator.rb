module Tomo
  class CLI
    class RulesEvaluator
      def self.evaluate(**kwargs)
        new(**kwargs).call
      end

      def initialize(rules:, argv:, state:, literal:, completions: nil)
        @rules = rules
        @argv = argv.dup
        @state = state
        @literal = literal
        @completions = completions || Completions.new(literal: literal)
      end

      def call
        until argv.empty?
          complete_if_needed(remaining_rules, *argv) if argv.length == 1
          rule, matched_args = match_next_rule
          complete_if_needed([rule], *matched_args) if argv.empty?
          rule.process(*matched_args, state: state)
          state.processed_rule(rule)
        end
      end

      private

      attr_reader :rules, :argv, :state, :literal, :completions

      def match_next_rule
        matched_rule, length = remaining_rules.find do |rule|
          matching_length = rule.match(argv.first, literal: literal)
          break [rule, matching_length] if matching_length
        end
        raise_unrecognized_args if matched_rule.nil?

        matched_args = argv.shift(length)
        [matched_rule, matched_args]
      end

      def complete_if_needed(matched_rules, *matched_args)
        return unless Completions.active?

        completions.print_completions_and_exit(matched_rules, *matched_args, state: state)
      end

      def remaining_rules
        rules.reject do |rule|
          state.processed?(rule) && !rule.multiple?
        end
      end

      def raise_unrecognized_args
        problem_arg = argv.first
        type = literal || !problem_arg.start_with?("-") ? "arg" : "option"

        raise CLI::Error, "#{Colors.yellow(problem_arg)} is not a recognized #{type} for this tomo command."
      end
    end
  end
end
