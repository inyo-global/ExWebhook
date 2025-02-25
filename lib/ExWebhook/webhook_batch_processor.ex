defmodule ExWebhook.BatchProcessor do
  @moduledoc """
  Webhook Batch Processor - This Module is responsible to send webhook messages grouped by tenant,
   in batches of `batch_size` and timeout of `batch_timeout`.
  The messages are grouped in a single [jsonl](https://jsonlines.org) payload.
  """
  use Broadway
  require Logger
  alias Broadway.BatchInfo
  alias Broadway.Message
  alias ExWebhook.WebhookExecutor

  def start_link(_opts) do
    options = Application.fetch_env!(:webhook, :batch_processor_options)
    producer_module = Keyword.fetch!(options, :producer_module)
    producer_options = Keyword.fetch!(options, :producer_options)
    batch_size = Keyword.fetch!(options, :batch_size)
    batch_timeout = Keyword.fetch!(options, :batch_timeout)

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
    Logger.info("processing batch with size #{batch_info.size} and key #{batch_info.batch_key}")

    result =
      messages
      |> Enum.map(& &1.data)
      |> Enum.map_join("\n", &Jason.encode!/1)
      |> WebhookExecutor.execute_webhook(batch_info.batch_key)

    case result do
      :ok ->
        Logger.info("batch with size #{batch_info.size} and key #{batch_info.batch_key} success")

      error ->
        Logger.error(
          "batch with size #{batch_info.size} and key #{batch_info.batch_key} failed with #{inspect(error)}"
        )
    end

    messages
  end
end
