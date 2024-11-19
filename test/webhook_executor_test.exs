defmodule ExWebhook.WebhookExecutorTest do
  alias ExWebhook.WebhookExecutor
  alias ExWebhook.Factory
  use ExUnit.Case, async: true


  test "When execute with success, then all records are saved" do
    hook = Factory.insert!(:webhook)
    assert :ok = WebhookExecutor.execute_webhook("test_payload", hook.tenant_id)
  end
end
