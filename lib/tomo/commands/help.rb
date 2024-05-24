# frozen_string_literal: true

module Tomo
  module Commands
    class Help
      def self.parse(argv)
        Default.parse([*argv, "--help"])
      end
    end
  end
end
