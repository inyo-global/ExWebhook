defmodule ExWebhook.BatchProcessorTest do
  use ExUnit.Case, async: true

  test "test serializing json and setting batch_key" do
    tenant_id = UUID.uuid4()
    ref = Broadway.test_message(ExWebhook.BatchProcessor, generate_message(tenant_id))

    assert_receive {:ack, ^ref,
                    [
                      %Broadway.Message{
                        data: %{"tenantId" => ^tenant_id},
                        batch_key: ^tenant_id
                      }
                    ], []}
  end

  test "test batch with more than 1k messages are splits in two" do
    tenant_id = UUID.uuid4()

    messages =
      1..(batch_size() * 2)
      |> Enum.map(fn _ -> generate_message(tenant_id) end)

    ref = Broadway.test_batch(ExWebhook.BatchProcessor, messages, batch_mode: :bulk)

    assert_receive {:ack, ^ref, successful, _failed}
    assert length(successful) == batch_size()
  end

  test "When batch reachs the timeout, them emit even if the max size is not reached" do
    tenant_id = UUID.uuid4()

    ref =
      Broadway.test_batch(ExWebhook.BatchProcessor, [generate_message(tenant_id)],
        batch_mode: :bulk
      )

    assert_receive {:ack, ^ref, successful, _failed}, batch_timeout() + 50
    assert length(successful) == 1
  end

  test "When batch does not reachs the timeout and neither the max size, do not emmit" do
    tenant_id = UUID.uuid4()

    ref =
      Broadway.test_batch(ExWebhook.BatchProcessor, [generate_message(tenant_id)],
        batch_mode: :bulk
      )

    refute_receive {:ack, ^ref, _successful, _failed}, batch_timeout() - 10
  end

  test "When messages have different tenant, then group it in different batchs" do
    tenant1_id = UUID.uuid4()
    tenant2_id = UUID.uuid4()

    ref =
      Broadway.test_batch(
        ExWebhook.BatchProcessor,
        [
          generate_message(tenant1_id),
          generate_message(tenant2_id),
          generate_message(tenant1_id),
          generate_message(tenant2_id)
        ],
        batch_mode: :bulk
      )

    assert_receive {:ack, ^ref,
                    [
                      %Broadway.Message{
                        data: %{"tenantId" => ^tenant1_id},
                        batch_key: ^tenant1_id
                      },
                      %Broadway.Message{
                        data: %{"tenantId" => ^tenant1_id},
                        batch_key: ^tenant1_id
                      }
                    ], _failed},
                   batch_timeout() + 50

    assert_receive {:ack, ^ref,
                    [
                      %Broadway.Message{
                        data: %{"tenantId" => ^tenant2_id},
                        batch_key: ^tenant2_id
                      },
                      %Broadway.Message{
                        data: %{"tenantId" => ^tenant2_id},
                        batch_key: ^tenant2_id
                      }
                    ], _failed},
                   batch_timeout() + 50
  end

  defp batch_timeout, do: Application.get_env(:webhook, :batch_processor_options)[:batch_timeout]

  defp batch_size, do: Application.fetch_env!(:webhook, :batch_processor_options)[:batch_size]

  defp generate_message(tenantId) do
    """
    {
        "product": "product",
        "agent": "agent",
        "tenantId": "#{tenantId}",
        "externalId": "0deb8996-d6de-4c1a-908f-537c7d4144d1",
        "status": "status",
        "receipt": "receipt",
        "rightToRefund": "rightToRefund",
        "contactInfo": "contactInfo",
        "cancellationDisclosure": "cancellationDisclosure",
        "externalTimestamp": "2024-11-08T01:05:30.787957118"
    }
    """
  end
end
