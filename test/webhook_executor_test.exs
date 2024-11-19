defmodule ExWebhook.WebhookExecutorTest do
  alias ExWebhook.Factory
  alias ExWebhook.WebhookExecutor
  use ExUnit.Case, async: true

  def setup do
    config = Testcontainers.PostgresContainer.new()
    {:ok, container} = Testcontainers.start_container(config)
    ExUnit.Callbacks.on_exit(fn -> Testcontainers.stop_container(container.container_id) end)
    {:ok, %{postgres: container}}
  end

  test "When execute with success, then all records are saved" do
    hook = Factory.insert!(:webhook)
    assert :ok = WebhookExecutor.execute_webhook("test_payload", hook.tenant_id)
  end
end
