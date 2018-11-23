require "json"

module Jam
  class Project
    class JsonParser
      def self.parse(path:, environment:)
        new(path, environment).call
      end

      def initialize(path, environment)
        @path = path
        @environment = environment
      end

      def call
        json = load_json
        envs = json.delete("environments") || {}

        json.merge(lookup_environment(envs)) do |key, orig, new|
          key == "settings" ? orig.merge(new) : new
        end
      end

      private

      attr_reader :path, :environment

      def load_json
        raise "Jam project (#{path}) not found" unless File.file?(path)

        JSON.parse(IO.read(path))
      end

      def lookup_environment(envs)
        if environment.nil?
          raise_no_environment_specified(envs) unless envs.empty?
          {}
        elsif environment == :auto
          envs.values.first || {}
        else
          envs.fetch(environment) do
            raise_unknown_environment(envs)
          end
        end
      end

      def raise_no_environment_specified(envs)
        raise "No environment specified! "\
              "Must be one of #{envs.keys.inspect}"
      end

      def raise_unknown_environment(envs)
        message = "Unknown environment #{environment.inspect}. "
        message << if envs.empty?
                     "This project does not have any environments."
                   else
                     "Must be one of #{envs.keys.inspect}"
                   end
        raise message
      end
    end
  end
end
