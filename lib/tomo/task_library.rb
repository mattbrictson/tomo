module Tomo
  class TaskLibrary
    include TaskAPI

    def initialize(context)
      @context = context
    end

    private

    attr_reader :context
  end
end
