defmodule ExWebhook.WebhookExecutor do
  @moduledoc """
  This module is reposible to execute the webhook request
  and save the result in the database
  """
  alias ExWebhook.Schema.Webhook
  alias ExWebhook.Schema.WebhookCall
  alias ExWebhook.WebhookCallRepository
  alias ExWebhook.WebhookRepository

  @spec execute_webhook(String.t(), String.t(), boolean()) :: :ok | :webhook_not_found
  def execute_webhook(payload, tenantId, is_batch) do
    hooks = WebhookRepository.list_webhooks(tenantId, is_batch)
    execute_hook(hooks, payload, is_batch)
  end

  defp execute_hook({:ok, []}, _payload, is_batch), do: :webhook_not_found

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

  defp execute_hook(error, _payload), do: error

  defp execute_hook(%{hook: hook, payload: payload, is_batch: is_batch}) do
    HTTPoison.post(
      hook.url,
      payload,
      [{"Content-Type", "application/jsonlines"}],
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
