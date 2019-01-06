module Tomo
  class Result
    def self.empty_success
      new(stdout: "", stderr: "", exit_status: 0)
    end

    attr_reader :stdout, :stderr, :exit_status

    def initialize(stdout:, stderr:, exit_status:)
      @stdout = stdout
      @stderr = stderr
      @exit_status = exit_status
      freeze
    end

    def success?
      exit_status.zero?
    end

    def failure?
      !success?
    end

    def output
      [stdout, stderr].compact.join
    end
  end
end
