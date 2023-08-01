concurrent_ver = "~> 1.1"

begin
  gem "concurrent-ruby", concurrent_ver
  require "concurrent"
rescue LoadError => e
  Tomo::Runtime::ConcurrentRubyLoadError.raise_with(e.message, version: concurrent_ver)
end

module Tomo
  class Runtime
    class ConcurrentRubyThreadPool
      include ::Concurrent::Promises::FactoryMethods

      def initialize(size)
        @executor = ::Concurrent::FixedThreadPool.new(size)
        @promises = []
      end

      def post(...)
        return if failure?

        promises << future_on(executor, ...)
          .on_rejection_using(executor) do |reason|
            self.failure = reason
          end

        nil
      end

      def run_to_completion
        promises_to_wait = promises.dup
        promises.clear
        zip_futures_on(executor, *promises_to_wait).value
        raise failure if failure?
      end

      def failure?
        !!failure
      end

      private

      attr_accessor :failure
      attr_reader :executor, :promises
    end
  end
end
