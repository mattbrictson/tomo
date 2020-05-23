require "test_helper"

class Tomo::HostTest < Minitest::Test
  def test_parse_hostname
    host = Tomo::Host.parse("app.example.com")
    assert_equal("app.example.com", host.address)
    assert_equal(22, host.port)
    assert_empty(host.roles)
    assert_nil(host.log_prefix)
    assert_nil(host.user)
  end

  def test_parse_hostname_with_user
    host = Tomo::Host.parse("deployer@app.example.com")
    assert_equal("app.example.com", host.address)
    assert_equal(22, host.port)
    assert_equal("deployer", host.user)
    assert_empty(host.roles)
    assert_nil(host.log_prefix)
  end

  def test_parse_ip_address_with_user
    host = Tomo::Host.parse("my.user@10.1.19.2")
    assert_equal("10.1.19.2", host.address)
    assert_equal(22, host.port)
    assert_equal("my.user", host.user)
    assert_empty(host.roles)
    assert_nil(host.log_prefix)
  end

  def test_parse_with_options
    host = Tomo::Host.parse("deployer@app.example.com", port: 8022, log_prefix: "one", roles: %w[db web])
    assert_equal("app.example.com", host.address)
    assert_equal(8022, host.port)
    assert_equal("deployer", host.user)
    assert_equal("one", host.log_prefix)
    assert_equal(%w[db web], host.roles)
  end
end
