module Tomo
  class CLI
    class Completions
      def self.activate
        @active = true
      end

      def self.active?
        defined?(@active) && @active
      end

      def initialize(literal: false, stdout: $stdout)
        @literal = literal
        @stdout = stdout
      end

      def print_completions_and_exit(rules, *args, state:)
        completions = completions_for(rules, *args, state)
        words = completions.map { |c| bash_word_for(c, args.last) }
        Tomo.logger.info(words.join("\n")) unless words.empty?
        CLI.exit
      end

      private

      attr_reader :literal, :stdout

      def completions_for(rules, *prefix_args, word, state)
        all_candidates(rules, prefix_args, state).select do |cand|
          next if !literal && redundant_option_completion?(cand, word)

          cand.start_with?(word) && cand != word
        end
      end

      def all_candidates(rules, prefix_args, state)
        rules.flat_map do |rule|
          rule.candidates(*prefix_args, literal: literal, state: state)
        end
      end

      def redundant_option_completion?(cand, word)
        # Don't complete switches until the user has typed at least "--"
        return true if cand.start_with?("-") && !word.start_with?("--")

        # Don't complete the =value part of long switch unless the user has
        # already typed at least up to the = sign.
        true if cand.match?(/\A--.*=/) && !word.match?(/\A--.*=/)
      end

      # bash tokenizes the user's input prior to completion, and expects the
      # completions we return to be only the last token of the string. So if the
      # user typed "rails:c[TAB]", bash expects the completion to be the part
      # after the ":" character. In other words we should return "console", not
      # "rails:console". The special tokens we need to consider are ":" and "=".
      #
      # For convenience we also distinguish a partial completion vs a full
      # completion. If it is a full completion we append a " " to the end of
      # the word so that the user can naturally begin typing the next option or
      # argument.
      def bash_word_for(completion, user_input)
        completion = "#{completion} " unless completion.end_with?("=")
        return completion unless user_input.match?(/[:=]/)

        completion.sub(/.*[:=]/, "")
      end
    end
  end
end
