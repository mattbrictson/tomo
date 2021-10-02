module Tomo
  class Configuration
    class RoleBasedTaskFilter
      def initialize
        @globs = {}
      end

      def freeze
        globs.freeze
        super
      end

      def add_role(name, task_specs)
        name = name.to_s
        task_globs = Array(task_specs).flatten.map { |spec| Glob.new(spec) }
        task_globs.each do |task_glob|
          (globs[task_glob] ||= []) << name
        end
      end

      def filter(tasks, host:)
        roles = host.roles
        roles = [""] if roles.empty?
        tasks.select do |task|
          roles.any? { |role| match?(task, role) }
        end
      end

      private

      attr_reader :globs

      def match?(task, role)
        task_globs = globs.keys.select { |glob| glob.match?(task) } # rubocop:disable Style/SelectByRegexp
        return true if task_globs.empty?

        roles = globs.values_at(*task_globs).flatten
        roles.include?(role)
      end
    end
  end
end
