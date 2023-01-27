require "bundler"
require "fileutils"
require "open3"
require "securerandom"
require "shellwords"
require "tmpdir"

module Tomo
  module Testing
    module Local
      def with_tomo_gemfile(&block)
        Local.with_tomo_gemfile(&block)
      end

      def in_temp_dir(token=nil, &block)
        Local.in_temp_dir(token, &block)
      end

      def capture(*command, raise_on_error: true)
        Local.capture(*command, raise_on_error: raise_on_error)
      end

      class << self
        def with_tomo_gemfile
          Bundler.with_original_env do
            gemfile = File.expand_path("../../../Gemfile", __dir__)
            ENV["BUNDLE_GEMFILE"] = gemfile
            yield
          end
        end

        def in_temp_dir(token=nil, &block)
          token ||= SecureRandom.hex(8)
          dir = File.join(Dir.tmpdir, "tomo_test_#{token}")
          FileUtils.mkdir_p(dir)
          Dir.chdir(dir, &block)
        end

        def capture(*command, raise_on_error: true)
          command_str = command.join(" ")
          progress(command_str) do
            output, status = Open3.capture2e(*command)

            raise "Command failed: #{command_str}\n#{output}" if raise_on_error && !status.success?

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
          Tomo::Console.interactive?
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
