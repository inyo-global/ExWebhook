defmodule ExWebhook.SingleProcessor do
  @moduledoc """
  Webhook Batch Processor - This Module is responsible to send webhook messages as it is. Without batching.
  """
  use Broadway
  require Logger
  alias ExWebhook.WebhookExecutor

  def start_link(_opts) do
    options = Application.fetch_env!(:webhook, :single_processor_options)
    producer_module = Keyword.fetch!(options, :producer_module)
    producer_options = Keyword.fetch!(options, :producer_options)

    Broadway.start_link(__MODULE__,
      name: __MODULE__,
      producer: [
        module: {producer_module, producer_options},
        concurrency: 1
      ],
      processors: [
        default: [concurrency: 1]
      ]
    )
  end

  @impl true
  @spec handle_message(any(), Broadway.Message.t(), any()) :: Broadway.Message.t()
  def handle_message(_processor_name, message = %Broadway.Message{data: message_data}, _context) do
    tenant_id =
      message_data
      |> Jason.decode!()
      |> Map.fetch!("tenantId")

    WebhookExecutor.execute_webhook(message_data, tenant_id)
    message
  end
end
