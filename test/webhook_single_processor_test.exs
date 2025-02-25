defmodule ExWebhook.SingleProcessorTest do
  use ExUnit.Case, async: true

  test "Messages are not grouped message" do
    tenant1_id = UUID.uuid4()
    tenant2_id = UUID.uuid4()

    ref1 = Broadway.test_message(ExWebhook.SingleProcessor, generate_message(tenant1_id))
    ref2 = Broadway.test_message(ExWebhook.SingleProcessor, generate_message(tenant2_id))

    assert_receive {:ack, ^ref1,
                    [
                      %Broadway.Message{
                        data: first_message
                      }
                    ], []}

    assert first_message =~ tenant1_id

    assert_receive {:ack, ^ref2,
                    [
                      %Broadway.Message{
                        data: second_message
                      }
                    ], []}

    assert second_message =~ tenant2_id
  end

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
