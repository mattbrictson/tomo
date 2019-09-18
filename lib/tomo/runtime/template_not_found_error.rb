module Tomo
  class Runtime
    class TemplateNotFoundError < Error
      attr_accessor :path

      def to_console
        "Template not found: #{yellow(path)}"
      end
    end
  end
end
