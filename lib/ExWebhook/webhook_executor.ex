defmodule ExWebhook.WebhookExecutor do
  @moduledoc """
  This module is reposible to execute the webhook request
  and save the result in the database
  """
  alias ExWebhook.Schema.Webhook
  alias ExWebhook.Schema.WebhookCall
  alias ExWebhook.WebhookCallRepository
  alias ExWebhook.WebhookRepository

  @spec execute_webhook(String.t(), String.t(), boolean(), String.t() | nil) ::
          :ok | :webhook_not_found
  def execute_webhook(payload, tenantId, is_batch, topic \\ nil) do
    WebhookRepository.list_webhooks(tenantId, is_batch)
    |> filter_hooks_by_topic(topic)
    |> execute_hook(payload, is_batch)
  end

  defp filter_hooks_by_topic({:ok, []}, _topic), do: {:ok, []}

  defp filter_hooks_by_topic({:ok, hooks}, topic) do
    hooks_to_process =
      if topic do
        Enum.filter(hooks, fn hook ->
          webhook_type_names = Enum.map(hook.webhook_types, fn type -> type.type_name end)
          Enum.member?(webhook_type_names, topic) or hook.webhook_types == []
        end)
      else
        hooks
      end

    {:ok, hooks_to_process}
  end

  defp execute_hook({:ok, []}, _payload, _is_batch), do: :webhook_not_found

  defp execute_hook({:ok, hooks}, payload, is_batch) do
    results =
      hooks
      |> Enum.map(&%{hook: &1, payload: payload, is_batch: is_batch})
      |> Enum.map(&execute_hook/1)
      |> Enum.reduce([], fn result, acc ->
        case result do
          {:ok, _} -> acc
          error -> [error | acc]
        end
      end)

    case results do
      [] -> :ok
      erros -> {:error, erros}
    end
  end

  defp execute_hook(%{hook: hook, payload: payload, is_batch: is_batch}) do
    HTTPoison.post(
      hook.url,
      payload,
      [{"Content-Type", content_type(is_batch)}],
      recv_timeout: 60_000
    )
    |> save_webhook_call(hook, payload)
  end

  defp content_type(true), do: "application/jsonlines"
  defp content_type(false), do: "application/json"

  defp save_webhook_call(
         {:ok, %HTTPoison.Response{status_code: status_code, body: body}},
         hook = %Webhook{},
         payload
       ) do
    %WebhookCall{
      webhook_id: hook.id,
      success: status_code >= 200 and status_code < 300,
      response_status: status_code,
      response_body: body,
      request_body: payload
    }
    |> save_webhook_call()
  end

  defp save_webhook_call(
         {:error, error = %HTTPoison.Error{}},
         hook = %Webhook{},
         payload
       ) do
    %WebhookCall{
      webhook_id: hook.id,
      success: false,
      error: HTTPoison.Error.message(error),
      request_body: payload
    }
    |> save_webhook_call()
  end

  defp save_webhook_call(webhook_call = %WebhookCall{}) do
    WebhookCallRepository.save_webhook_call(webhook_call)
  end
end
