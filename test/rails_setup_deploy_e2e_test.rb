require "test_helper"

require "fileutils"
require "net/http"
require "securerandom"
require "tmpdir"

class RailsSetupDeployE2ETest < Minitest::Test
  def setup
    @docker = Tomo::Testing::DockerImage.new
    @docker.build_and_run
  end

  def teardown
    @docker.stop
  end

  def test_rails_setup_deploy
    in_cloned_rails_repo do
      Tomo::Testing::Local.bundle_exec("tomo init")
      config = IO.read(".tomo/config.rb")
      config.sub!(
        /host ".*"/,
        %Q(host "#{@docker.host.user}@#{@docker.host.address}", )\
        "port: #{@docker.host.port}"
      )
      config << <<~CONFIG
        set(#{@docker.ssh_settings.inspect})
      CONFIG
      IO.write(".tomo/config.rb", config)

      Tomo::Testing::Local.bundle_exec(
        "tomo run env:set "\
        "DATABASE_URL=sqlite3:/var/www/rails-new/shared/production.sqlite3 "\
        "SECRET_KEY_BASE=#{SecureRandom.hex(64)}"
      )
      Tomo::Testing::Local.bundle_exec("tomo setup")
      Tomo::Testing::Local.bundle_exec("tomo deploy")

      rails_uri = URI("http://localhost:#{@docker.puma_port}/")
      rails_http_response = Net::HTTP.get(rails_uri)
      assert_match(/rails-default-error-page/, rails_http_response)
    end
  end

  private

  def in_cloned_rails_repo(&block)
    dir = File.join(Dir.tmpdir, "tomo_test_#{SecureRandom.hex(8)}")
    FileUtils.mkdir_p(dir)
    Dir.chdir(dir) do
      repo = "https://github.com/mattbrictson/rails-new.git"
      Tomo::Testing::Local.capture("git clone #{repo}")
      Dir.chdir("rails-new", &block)
    end
  end
end
