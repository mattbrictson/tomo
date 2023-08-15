module Tomo::Plugin::Puma
  class Tasks < Tomo::TaskLibrary
    SystemdUnit = Struct.new(:name, :template, :path)

    def setup_systemd # rubocop:disable Metrics/AbcSize
      linger_must_be_enabled!

      setup_directories
      remote.write template: socket.template, to: socket.path
      remote.write template: service.template, to: service.path

      remote.run "systemctl --user daemon-reload"
      remote.run "systemctl", "--user", "enable", service.name, socket.name
    end

    %i[start stop status].each do |action|
      define_method(action) do
        remote.run "systemctl", "--user", action, socket.name, service.name
      end
    end

    def restart
      remote.run "systemctl", "--user", "start", socket.name
      remote.run "systemctl", "--user", "restart", service.name
    end

    def check_active
      logger.info "Checking if puma is active and listening on port #{port}..."

      active = wait_until { dry_run? || (assert_active! && listening?) }
      remote.run("systemctl", "--user", "status", service.name)
      return if active

      logger.warn "Timed out waiting for puma to respond on port #{port}"
    end

    def log
      remote.attach "journalctl", "-q", raw("--user-unit=#{service.name.shellescape}"), *settings[:run_args]
    end

    def tail_log
      remote.attach "journalctl -q --user-unit=#{service.name.shellescape} -f"
    end

    private

    def port
      settings[:puma_port]
    end

    def service
      SystemdUnit.new(
        settings[:puma_systemd_service],
        paths.puma_systemd_service_template,
        paths.puma_systemd_service
      )
    end

    def socket
      SystemdUnit.new(
        settings[:puma_systemd_socket],
        paths.puma_systemd_socket_template,
        paths.puma_systemd_socket
      )
    end

    def linger_must_be_enabled!
      linger_users = remote.list_files(
        "/var/lib/systemd/linger", raise_on_error: false
      )
      return if dry_run? || linger_users.include?(remote.host.user)

      die <<~ERROR.strip
        Linger must be enabled for the #{remote.host.user} user in order for
        puma to stay running in the background via systemd. Run the following
        command as root:

          loginctl enable-linger #{remote.host.user}
      ERROR
    end

    def setup_directories
      files = [service.path, socket.path].compact
      dirs = files.map { |f| f.dirname.to_s }
      remote.mkdir_p dirs.uniq
    end

    def wait_until
      timeout = settings[:puma_check_timeout].to_i
      start = Time.now.to_i
      delay = 1

      loop do
        sleep delay
        return true if yield

        elapsed = Time.now.to_i - start
        return false if elapsed >= timeout

        delay = [delay + 1, timeout - elapsed].min
      end
    end

    def assert_active!
      return true if remote.run? "systemctl", "--user", "is-active", service.name, silent: true, raise_on_error: false

      remote.run "systemctl", "--user", "status", service.name, raise_on_error: false
      remote.run "journalctl -q -n 50 --user-unit=#{service.name.shellescape}", raise_on_error: false

      die "puma failed to start (see previous systemctl and journalctl output)"
    end

    def listening?
      test_url = "http://localhost:#{port}"
      remote.run? "curl -sS --connect-timeout 1 --max-time 10 #{test_url} > /dev/null"
    end
  end
end
