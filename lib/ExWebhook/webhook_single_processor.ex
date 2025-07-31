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
  def handle_message(_processor_name, message = %Broadway.Message{data: message_data, metadata: metadata}, _context) do
    Logger.info("processing single message #{inspect(message_data)}")

    topic_identifier =
      Map.get(metadata, :topic) ||
      (Map.get(metadata, :queue_url) |> case do
         nil -> nil
         url -> URI.parse(url).path |> Path.basename()
       end)

    tenant_id =
      message_data
      |> Jason.decode!()
      |> Map.fetch!("tenantId")

    result = WebhookExecutor.execute_webhook(message_data, tenant_id, false, topic_identifier)

    case result do
      :ok ->
        Logger.info("message #{message_data} processed with success")

      error ->
        Logger.error(Logger.info("message #{message_data} failed with #{inspect(error)}"))
    end

    message
  end
end
