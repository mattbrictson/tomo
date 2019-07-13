require "test_helper"

require "net/http"
require "securerandom"

class RailsSetupDeployE2ETest < Minitest::Test
  include Tomo::Testing::Local

  def setup
    @docker = Tomo::Testing::DockerImage.new
    @docker.build_and_run
  end

  def teardown
    @docker.stop
  end

  def test_rails_setup_deploy
    in_cloned_rails_repo do
      bundle_exec("tomo init")
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

      bundle_exec(
        "tomo run env:set "\
        "DATABASE_URL=sqlite3:/var/www/rails-new/shared/production.sqlite3 "\
        "SECRET_KEY_BASE=#{SecureRandom.hex(64)}"
      )
      bundle_exec("tomo setup")
      bundle_exec("tomo deploy")

      rails_uri = URI("http://localhost:#{@docker.puma_port}/")
      rails_http_response = Net::HTTP.get(rails_uri)
      assert_match(/rails-default-error-page/, rails_http_response)
    end
  end

  private

  def bundle_exec(command)
    with_tomo_gemfile do
      full_cmd = "bundle exec #{command}"
      puts ">>> #{full_cmd}"
      system(full_cmd) || raise("Command failed")
    end
  end

  def in_cloned_rails_repo(&block)
    in_temp_dir do
      repo = "https://github.com/mattbrictson/rails-new.git"
      capture("git clone #{repo}")
      Dir.chdir("rails-new", &block)
    end
  end
end
