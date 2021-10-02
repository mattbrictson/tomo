#!/usr/bin/env ruby

# THIS SCRIPT IS FOR TESTING PURPOSES ONLY.
#
# We use Docker to run tomo deploy tests. Docker is not able to run systemd, but
# tomo needs systemd for starting long-lived processes (e.g. puma). This script
# simulates the behavior of systemctl commands so that a tomo deploy can succeed
# in a Docker container where the real systemctl is unavailable.
#
# This basic workflow is supported:
#
# 1. systemctl --user enable [units...]
# 2. systemctl --user start [units...]
# 3. systemctl --user restart [units...]
# 4. systemctl --user is-active [units...]
# 5. systemctl --user status [units...]
#
# No other commands or options are supported. The only configuration that this
# script understands is the ExecStart and WorkingDirectory attributes in a
# *.service file that is expected to be installed in ~/.config/systemd/user/.
#
# This script will fork and exec the command listed in ExecStart and store the
# resulting PID so that it can later be used when stopping or restarting the
# service. It does not monitor the process, handle stdout/stderr of the process,
# or do any of the real work that systemd is designed to handle. It simply is
# the bare minimum behavior needed for tomo deploy to pass an E2E test.

require "pstore"

COMMANDS = %w[
  daemon-reload
  enable
  is-active
  restart
  start
  status
  stop
].freeze

def main(args)
  args = args.dup
  raise "First arg must be --user" unless args.shift == "--user"
  raise "Missing command" if args.empty?

  command = args.shift
  raise "Unknown command: #{command}" unless COMMANDS.include?(command)

  run(command, args)
end

def run(command, args)
  return daemon_reload(args) if command == "daemon-reload"
  raise "#{command} requires an argument" if args.empty?

  args.each { |name| Unit.find(name).public_send(command.tr("-", "_")) }
end

def daemon_reload(args)
  raise "daemon-reload does not accept arguments" unless args.empty?
end

class Unit
  def self.find(name)
    path = File.join(File.expand_path("~/.config/systemd/user/"), name)
    raise "Unknown unit: #{name}" unless File.file?(path)
    return Service.new(name, File.read(path)) if name.end_with?(".service")

    new(name, File.read(path))
  end

  def initialize(name, spec)
    @name = name
    @spec = spec
  end

  def enable
    with_persistent_state { |state| state[:enabled] = true }
  end

  def status
    puts "● #{name}"
    puts "   Loaded: loaded (enabled; vendor preset: enabled)" if enabled?
  end

  def start
    must_be_enabled!
  end

  def stop
    must_be_enabled!
  end

  def restart
    must_be_enabled!
  end

  private

  attr_reader :name, :spec

  def must_be_enabled!
    raise "#{name} must be enabled first" unless enabled?
  end

  def enabled?
    with_persistent_state { |state| state[:enabled] }
  end

  def with_persistent_state
    @pstore ||= begin
      pstore_path = File.expand_path("~/.config/systemd/state.db")
      PStore.new(pstore_path)
    end

    @pstore.transaction do
      state = @pstore[name] ||= {}
      yield(state)
    end
  end
end

class Service < Unit
  def is_active # rubocop:disable Naming/PredicateName
    exit(false) unless started?
    puts "active"
  end

  def start
    super
    raise "#{name} is already running" if started?

    working_dir, executable = parse

    if (pid = Process.fork)
      with_persistent_state { |state| state[:pid] = pid }
      Process.detach(pid)
      return
    end

    with_detached_io { Dir.chdir(working_dir) { Process.exec(executable) } }
  end

  def stop
    with_persistent_state do |state|
      pid = state.delete(:pid)
      Process.kill("TERM", pid) unless pid.nil?
    end
  end

  def restart
    super
    stop if started?
    start
  end

  def status
    super
    puts "   Active: active (running)" if started?
  end

  private

  def started?
    with_persistent_state { |state| !state[:pid].nil? }
  end

  def parse
    config = spec.scan(/^([^\s=]+)=\s*(\S.*?)\s*$/).to_h
    working_dir = config["WorkingDirectory"] || File.expand_path("~")
    executable = config.fetch("ExecStart") do
      raise "#{name} is missing ExecStart attribute"
    end

    [working_dir, executable]
  end

  def with_detached_io
    null_in = File.open(File::NULL, "r")
    null_out = File.open(File::NULL, "w")
    $stdin.reopen(null_in)
    $stderr.reopen(null_out)
    $stdout.reopen(null_out)
    yield
  end
end

main(ARGV) if $PROGRAM_NAME == __FILE__
