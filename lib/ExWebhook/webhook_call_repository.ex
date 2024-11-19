defmodule ExWebhook.WebhookCallRepository do
  @moduledoc """
  Webhook Repository
  """
  alias ExWebhook.DatabaseUtils
  alias ExWebhook.Schema.WebhookCall
  alias ExWebhook.Repo
  alias ExWebhook.DatabaseUtils

  @spec save_webhook_call(WebhookCall.t()) ::
          {:ok, [WebhookCall.t()] | DatabaseUtils.database_error()}
  def save_webhook_call(webhook_call) do
    DatabaseUtils.safe_call(fn -> Repo.insert(webhook_call) end)
  end
end
