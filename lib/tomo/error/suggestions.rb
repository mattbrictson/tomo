module Tomo
  class Error
    class Suggestions
      def initialize(dictionary:, word:)
        @dictionary = dictionary
        @word = word
      end

      def any?
        to_a.any?
      end

      def to_a
        @_suggestions ||= if defined?(DidYouMean::SpellChecker)
                            checker = DidYouMean::SpellChecker.new(dictionary: dictionary)
                            suggestions = checker.correct(word)
                            suggestions || []
                          else
                            []
                          end
      end

      def to_console
        return unless any?

        sentence = to_sentence(to_a.map { |word| Colors.blue(word) })
        "\nDid you mean #{sentence}?\n"
      end

      private

      attr_reader :dictionary, :word

      def to_sentence(words)
        return words.first if words.length == 1
        return words.join(" or ") if words.length == 2

        words[0...-1].join(", ") + ", or " + words.last
      end
    end
  end
end
