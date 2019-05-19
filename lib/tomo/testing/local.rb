require "bundler"
require "open3"
require "shellwords"

module Tomo
  module Testing
    module Local
      class << self
        def bundle_exec(command)
          gemfile = File.expand_path("../../../Gemfile", __dir__)
          full_cmd = "bundle exec --gemfile=#{gemfile.shellescape} #{command}"
          Bundler.with_original_env do
            puts ">>> #{full_cmd}"
            system(full_cmd) || raise("Command failed")
          end
        end

        def capture(command, raise_on_error: true)
          progress(command) do
            output, status = Open3.capture2e(command)

            if raise_on_error && !status.success?
              raise "Command failed: #{command}\n#{output}"
            end

            output
          end
        end

        private

        def progress(message, &block)
          return with_progress(message, &block) if interactive?

          thread = Thread.new(&block)
          return thread.value if wait_for_exit(thread, 4)

          puts "#{message} ..."
          wait_for_exit(thread)
          puts "#{message} ✔"

          thread.value
        end

        def with_progress(message, &block)
          spinner = %w[⠋ ⠙ ⠹ ⠸ ⠼ ⠴ ⠦ ⠧ ⠇ ⠏].cycle
          thread = Thread.new(&block)
          return thread.value if wait_for_exit(thread, 4)

          print "#{spinner.next} #{message}..."
          loop do
            break if wait_for_exit(thread, 0.2)

            print "\r#{spinner.next} #{message}..."
          end
          puts "\r✔ #{message}..."
          thread.value
        end

        def interactive?
          Tomo::Console.interactive? && !ENV["_TOMO_CONTAINER"]
        end

        def wait_for_exit(thread, seconds=nil)
          thread.join(seconds)
        rescue StandardError
          # Sanity check. If we get an exception, the thread should be dead.
          raise if thread.alive?

          thread
        end
      end
    end
  end
end
