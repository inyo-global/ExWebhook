defmodule ExWebhook.SingleProcessorTest do
  use ExUnit.Case, async: true

  test "Messages are not grouped message" do
    tenant1_id = UUID.uuid4()
    tenant2_id = UUID.uuid4()
    tenant3_id = UUID.uuid4()

    {message1, metadata1} = generate_message(tenant1_id, :kafka)
    {message2, metadata2} = generate_message(tenant2_id, :kafka)
    {message3, metadata3} = generate_message(tenant3_id, :sqs)
    ref1 = Broadway.test_message(ExWebhook.SingleProcessor, message1, metadata: metadata1)
    ref2 = Broadway.test_message(ExWebhook.SingleProcessor, message2, metadata: metadata2)
    ref3 = Broadway.test_message(ExWebhook.SingleProcessor, message3, metadata: metadata3)

    assert_receive {:ack, ^ref1,
                    [
                      %Broadway.Message{
                        data: captured_first_message
                      }
                    ], []}

    assert captured_first_message =~ tenant1_id

    assert_receive {:ack, ^ref2,
                    [
                      %Broadway.Message{
                        data: captured_second_message
                      }
                    ], []}

    assert captured_second_message =~ tenant2_id

    assert_receive {:ack, ^ref3,
                    [
                      %Broadway.Message{
                        data: captured_third_message
                      }
                    ], []}

    assert captured_third_message =~ tenant3_id
  end

  def generate_message(tenant_id, producer_type, topic_or_queue_name \\ "default") do
    data = %{
      "tenantId" => tenant_id,
      "generated_at" => DateTime.utc_now()
    }

    metadata =
      case producer_type do
        :kafka ->
          %{
            topic: topic_or_queue_name,
            partition: 0,
            offset: :rand.uniform(1_000_000),
            timestamp: DateTime.utc_now()
          }

        :sqs ->
          %{
            queue_url: "https://sqs.sa-east-1.amazonaws.com/123456789012/#{topic_or_queue_name}",
            receipt_handle: "simulated-receipt-handle-#{:rand.uniform(1_000_000)}",
            message_id: "simulated-message-id-#{:rand.uniform(1_000_000)}"
          }

        _ ->
          %{}
      end

    final_data = Jason.encode!(data)

    {final_data, metadata}
  end
end
