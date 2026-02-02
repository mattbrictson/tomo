# frozen_string_literal: true

class Tomo::Runtime::ExecutionPlanTest < TomoTest
  def test_single_host_run_plan
    runtime = single_host_config.build_runtime
    plan = runtime.execution_plan_for(["core:clean_releases"])
    assert_equal(<<~PLAN.strip, plan.explain)
      CONNECT deployer@app.example.com
      RUN core:clean_releases ON deployer@app.example.com
    PLAN
  end

  def test_multi_host_run_plan
    runtime = role_based_multi_host_config.build_runtime
    plan = runtime.execution_plan_for(["core:clean_releases"])
    assert_equal(<<~PLAN.strip, plan.explain)
      CONCURRENTLY (2 THREADS):
        = CONNECT deployer@worker.example.com
        = CONNECT deployer@web.example.com
      CONCURRENTLY (2 THREADS):
        = RUN core:clean_releases ON deployer@worker.example.com
        = RUN core:clean_releases ON deployer@web.example.com
    PLAN
  end

  def test_multi_host_run_plan_with_no_concurrency
    config = role_based_multi_host_config
    config.settings[:concurrency] = 1
    runtime = config.build_runtime
    plan = runtime.execution_plan_for(["core:clean_releases"])
    assert_equal(<<~PLAN.strip, plan.explain)
      CONNECT deployer@worker.example.com
      CONNECT deployer@web.example.com
      RUN core:clean_releases ON deployer@worker.example.com
      RUN core:clean_releases ON deployer@web.example.com
    PLAN
  end

  def test_single_host_setup_plan
    runtime = single_host_config.build_runtime
    plan = runtime.execution_plan_for(setup_tasks)
    assert_equal(<<~PLAN.strip, plan.explain)
      CONNECT deployer@app.example.com
      RUN env:setup ON deployer@app.example.com
      RUN nodenv:install ON deployer@app.example.com
      RUN rbenv:install ON deployer@app.example.com
    PLAN
  end

  def test_multi_host_setup_plan
    runtime = role_based_multi_host_config.build_runtime
    plan = runtime.execution_plan_for(setup_tasks)
    assert_equal(<<~PLAN.strip, plan.explain)
      CONCURRENTLY (2 THREADS):
        = CONNECT deployer@worker.example.com
        = CONNECT deployer@web.example.com
      CONCURRENTLY (2 THREADS):
        = RUN env:setup ON deployer@worker.example.com
        = RUN env:setup ON deployer@web.example.com
      CONCURRENTLY (2 THREADS):
        = RUN nodenv:install ON deployer@worker.example.com
        = RUN nodenv:install ON deployer@web.example.com
      CONCURRENTLY (2 THREADS):
        = RUN rbenv:install ON deployer@worker.example.com
        = RUN rbenv:install ON deployer@web.example.com
    PLAN
  end

  def test_multi_host_setup_plan_with_no_concurrency
    config = role_based_multi_host_config
    config.settings[:concurrency] = 1
    runtime = config.build_runtime
    plan = runtime.execution_plan_for(setup_tasks)
    assert_equal(<<~PLAN.strip, plan.explain)
      CONNECT deployer@worker.example.com
      CONNECT deployer@web.example.com
      RUN env:setup ON deployer@worker.example.com
      RUN env:setup ON deployer@web.example.com
      RUN nodenv:install ON deployer@worker.example.com
      RUN nodenv:install ON deployer@web.example.com
      RUN rbenv:install ON deployer@worker.example.com
      RUN rbenv:install ON deployer@web.example.com
    PLAN
  end

  def test_single_host_setup_plan_with_privileged_task
    config = single_host_config
    runtime = config.build_runtime
    plan = runtime.execution_plan_for(
      setup_tasks + [(+"puma:setup_systemd").extend(Tomo::Runtime::PrivilegedTask)]
    )
    assert_equal(<<~PLAN.strip, plan.explain)
      CONCURRENTLY (2 THREADS):
        = CONNECT deployer@app.example.com
        = CONNECT root@app.example.com
      RUN env:setup ON deployer@app.example.com
      RUN nodenv:install ON deployer@app.example.com
      RUN rbenv:install ON deployer@app.example.com
      RUN puma:setup_systemd ON root@app.example.com
    PLAN
  end

  def test_multi_host_setup_plan_with_privileged_task
    config = role_based_multi_host_config
    runtime = config.build_runtime
    plan = runtime.execution_plan_for(
      setup_tasks + [(+"puma:setup_systemd").extend(Tomo::Runtime::PrivilegedTask)]
    )
    assert_equal(<<~PLAN.strip, plan.explain)
      CONCURRENTLY (3 THREADS):
        = CONNECT deployer@worker.example.com
        = CONNECT deployer@web.example.com
        = CONNECT root@web.example.com
      CONCURRENTLY (2 THREADS):
        = RUN env:setup ON deployer@worker.example.com
        = RUN env:setup ON deployer@web.example.com
      CONCURRENTLY (2 THREADS):
        = RUN nodenv:install ON deployer@worker.example.com
        = RUN nodenv:install ON deployer@web.example.com
      CONCURRENTLY (2 THREADS):
        = RUN rbenv:install ON deployer@worker.example.com
        = RUN rbenv:install ON deployer@web.example.com
      RUN puma:setup_systemd ON root@web.example.com
    PLAN
  end

  def test_single_host_deploy_plan_with_batches
    runtime = single_host_config.build_runtime
    plan = runtime.execution_plan_for(deploy_tasks_with_batches)
    assert_equal(<<~PLAN.strip, plan.explain)
      CONNECT deployer@app.example.com
      RUN env:update ON deployer@app.example.com
      RUN git:create_release ON deployer@app.example.com
      RUN bundler:install ON deployer@app.example.com
      RUN core:symlink_current ON deployer@app.example.com
      RUN puma:restart ON deployer@app.example.com
      RUN core:clean_releases ON deployer@app.example.com
      RUN core:log_revision ON deployer@app.example.com
    PLAN
  end

  def test_multi_host_deploy_plan_with_batches
    runtime = role_based_multi_host_config.build_runtime
    plan = runtime.execution_plan_for(deploy_tasks_with_batches)
    assert_equal(<<~PLAN.strip, plan.explain)
      CONCURRENTLY (2 THREADS):
        = CONNECT deployer@worker.example.com
        = CONNECT deployer@web.example.com
      CONCURRENTLY (2 THREADS):
        = IN SEQUENCE:
            RUN env:update ON deployer@worker.example.com
            RUN git:create_release ON deployer@worker.example.com
            RUN bundler:install ON deployer@worker.example.com
        = IN SEQUENCE:
            RUN env:update ON deployer@web.example.com
            RUN git:create_release ON deployer@web.example.com
            RUN bundler:install ON deployer@web.example.com
      CONCURRENTLY (2 THREADS):
        = RUN core:symlink_current ON deployer@worker.example.com
        = RUN core:symlink_current ON deployer@web.example.com
      CONCURRENTLY (2 THREADS):
        = IN SEQUENCE:
            RUN core:clean_releases ON deployer@worker.example.com
            RUN core:log_revision ON deployer@worker.example.com
        = IN SEQUENCE:
            RUN puma:restart ON deployer@web.example.com
            RUN core:clean_releases ON deployer@web.example.com
            RUN core:log_revision ON deployer@web.example.com
    PLAN
  end

  private

  def setup_tasks
    %w[
      env:setup
      nodenv:install
      rbenv:install
    ]
  end

  def deploy_tasks_with_batches
    [
      [
        "env:update",
        "git:create_release",
        "bundler:install"
      ],
      "core:symlink_current",
      [
        "puma:restart",
        "core:clean_releases",
        "core:log_revision"
      ]
    ]
  end

  def base_config
    Tomo::Configuration.new.tap do |config|
      config.plugins = %w[env git nodenv rbenv bundler rails puma]
    end
  end

  def single_host_config
    base_config.tap do |config|
      config.hosts << Tomo::Host.parse("deployer@app.example.com")
    end
  end

  def role_based_multi_host_config
    base_config.tap do |config|
      config.task_filter.add_role("puma", ["puma:*"])
      config.hosts << Tomo::Host.parse("deployer@worker.example.com")
      config.hosts << Tomo::Host.parse(
        "deployer@web.example.com", roles: ["puma"]
      )
    end
  end
end
