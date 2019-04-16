module Tomo
  module Commands
    class CompletionScript
      def self.parse(_argv)
        puts <<~'SCRIPT'
          # TOMO COMPLETIONS FOR BASH
          #
          # Assuming tomo is in your PATH, you can install tomo bash completions by
          # adding this line to your .bashrc:
          #
          #   eval "$(tomo completion-script)"
          #
          # The eval technique is a bit slow but ensures bash is always using the
          # latest version of the tomo completion script.
          #
          # Alternatively, you can copy and paste the current version of the script
          # into your .bashrc. The full script is listed below.

          _tomo_complete() {
            local cur="${COMP_WORDS[COMP_CWORD]}"
            local prev="${COMP_WORDS[COMP_CWORD-1]}"

            if [[ $prev == "-c" || $prev == "--config" ]]; then
              COMPREPLY=($(compgen -f -- ${cur}))
              return 0
            fi

            if [[ "${COMP_LINE: -1}" == " " ]]; then
              command=${COMP_LINE/tomo/tomo --complete}
            else
              command=${COMP_LINE/tomo/tomo --complete-word}
            fi

            suggestions=$($command)
            local IFS=$'\n'
            COMPREPLY=($suggestions)
            return 0
          }

          complete -o nospace -F _tomo_complete tomo

        SCRIPT
      end
    end
  end
end
