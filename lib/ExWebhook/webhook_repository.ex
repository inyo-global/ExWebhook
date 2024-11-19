defmodule ExWebhook.WebhookRepository do
  @moduledoc """
  Webhook Repository
  """
  alias ExWebhook.DatabaseUtils
  alias ExWebhook.Schema.Webhook
  alias ExWebhook.Repo
  alias ExWebhook.DatabaseUtils
  import Ecto.Query

  @spec list_webhooks(binary(), boolean()) :: {:ok, [Webhook.t()]} | DatabaseUtils.database_error()
  def list_webhooks(tenant, is_batch) do
    query = from w in Webhook,
          where: [tenant_id: ^tenant, is_batch: ^is_batch],
          select: w
    DatabaseUtils.safe_call(fn -> Repo.all(query) end)
  end

  @spec insert(Webhook.t()) :: {:ok, Webhook.t() | DatabaseUtils.database_error()}
  def insert(webhook) do
    DatabaseUtils.safe_call(fn -> Repo.insert!(webhook) end)
  end

end
