defmodule ExWebhook.WebhookExecutorTest do
  alias ExWebhook.Factory
  alias ExWebhook.WebhookExecutor
  use ExUnit.Case, async: true

  test "When execute success, then all records are saved" do
    hook1 = Factory.insert!(:webhook)
    assert :ok = WebhookExecutor.execute_webhook("test_payload", hook1.tenant_id, true)
    assert :ok = WebhookExecutor.execute_webhook("test_payload", hook1.tenant_id, true, "any")

    hook2 = Factory.insert!(:webhook, %{is_batch: false})
    assert :ok = WebhookExecutor.execute_webhook("test_payload", hook2.tenant_id, false)
    assert :ok = WebhookExecutor.execute_webhook("test_payload", hook2.tenant_id, false, "any")
  end

  test "When execute success with events, then all records are saved" do
    hook1 = Factory.insert!(:webhook, %{}, ["user.created", "user.updated"])

    assert :ok =
             WebhookExecutor.execute_webhook(
               "test_payload",
               hook1.tenant_id,
               true,
               "user.created"
             )

    assert :ok =
             WebhookExecutor.execute_webhook(
               "test_payload",
               hook1.tenant_id,
               true,
               "user.updated"
             )

    assert :webhook_not_found =
             WebhookExecutor.execute_webhook("test_payload", hook1.tenant_id, true, "any")

    assert :webhook_not_found =
             WebhookExecutor.execute_webhook("test_payload", hook1.tenant_id, true, "any")

    hook2 = Factory.insert!(:webhook, %{is_batch: false}, ["user.created", "user.updated"])

    assert :ok =
             WebhookExecutor.execute_webhook(
               "test_payload",
               hook2.tenant_id,
               false,
               "user.created"
             )

    assert :ok =
             WebhookExecutor.execute_webhook(
               "test_payload",
               hook2.tenant_id,
               false,
               "user.updated"
             )

    assert :webhook_not_found =
             WebhookExecutor.execute_webhook("test_payload", hook2.tenant_id, false, "any")

    assert :webhook_not_found =
             WebhookExecutor.execute_webhook("test_payload", hook2.tenant_id, false, "any")
  end
end
