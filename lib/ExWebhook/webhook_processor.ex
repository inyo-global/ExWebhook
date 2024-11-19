defmodule ExWebhook.Processor do
  @moduledoc """
  Webhook Processor
  """
  use Broadway
  alias Broadway.BatchInfo
  alias Broadway.Message
  alias ExWebhook.WebhookExecutor

  def start_link(_opts) do
    producer_module = Application.fetch_env!(:webhook, :producer_module)
    producer_options = Application.get_env(:webhook, :producer_options, [])
    batch_size = Application.get_env(:webhook, :batch_size, [])
    batch_timeout = Application.get_env(:webhook, :batch_timeout, [])

    Broadway.start_link(__MODULE__,
      name: __MODULE__,
      producer: [
        module: {producer_module, producer_options},
        concurrency: 1,
        rate_limiting: [allowed_messages: batch_size, interval: batch_timeout]
      ],
      processors: [
        default: [concurrency: 1]
      ],
      batchers: [
        batch_webhook: [
          batch_size: batch_size,
          batch_timeout: batch_timeout,
          concurrency: 1
        ]
      ]
    )
  end

  @impl true
  @spec handle_message(any(), Broadway.Message.t(), any()) :: Broadway.Message.t()
  def handle_message(_processor_name, message, _context) do
    message =
      message
      |> Message.put_batcher(:batch_webhook)
      |> Message.update_data(&Jason.decode!/1)

    message
    |> Message.put_batch_key(message.data["tenantId"])
  end

  @impl true
  @spec handle_batch(:batch_webhook, [Broadway.Message.t()], BatchInfo.t(), any()) :: any()
  def handle_batch(:batch_webhook, messages, batch_info, _) do
    messages
    |> Enum.map(& &1.data)
    |> Enum.map_join("\n", &Jason.encode!/1)
    |> WebhookExecutor.execute_webhook(batch_info.batch_key)

    messages
  end
end
