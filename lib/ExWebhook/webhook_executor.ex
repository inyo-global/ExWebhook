defmodule ExWebhook.WebhookExecutor do
  @moduledoc """
  This module is reposible to execute the webhook request
  and save the result in the database
  """
  alias ExWebhook.DatabaseUtils
  alias ExWebhook.Schema.Webhook
  alias ExWebhook.Schema.WebhookCall
  alias ExWebhook.WebhookCallRepository
  alias ExWebhook.WebhookRepository

  @spec execute_webhook(String.t(), String.t()) :: :ok | :webhook_not_found
  def execute_webhook(payload, tenantId) do
    execute_hook(WebhookRepository.list_webhooks(tenantId, true), payload)
  end

  defp execute_hook({:ok, []}, _payload), do: :webhook_not_found

  defp execute_hook({:ok, hooks}, payload) do
    results =
      hooks
      |> Enum.map(&%{hook: &1, payload: payload})
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

  @spec execute_webhook(String.t(), DatabaseUtils.database_error()) :: :ok
  defp execute_hook(error, _payload), do: error

  defp execute_hook(%{hook: hook, payload: payload}) do
    HTTPoison.post(
      hook.url,
      payload,
      [{"Content-Type", "application/jsonlines"}],
      recv_timeout: 60_000
    )
    |> save_webhook_call(hook, payload)
  end

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
         {:error, %HTTPoison.Error{reason: reason}},
         hook = %Webhook{},
         payload
       ) do
    %WebhookCall{
      webhook_id: hook.id,
      success: false,
      error: to_string(reason),
      request_body: payload
    }
    |> save_webhook_call()
  end

  defp save_webhook_call(webhook_call = %WebhookCall{}) do
    WebhookCallRepository.save_webhook_call(webhook_call)
  end
end
