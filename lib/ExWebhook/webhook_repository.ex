defmodule ExWebhook.WebhookRepository do
  @moduledoc """
  Webhook Repository
  """
  import Ecto.Query
  alias ExWebhook.DatabaseUtils
  alias ExWebhook.Repo
  alias ExWebhook.Schema.Webhook

  @spec list_webhooks(binary(), boolean() | nil) ::
          {:ok, [Webhook.t()]} | DatabaseUtils.database_error()
  def list_webhooks(tenant, is_batch) do
    query =
      from(w in Webhook,
        where: w.tenant_id == ^tenant,
        select: w
      )

    query =
      if is_nil(is_batch) do
        query
      else
        where(query, [w], w.is_batch == ^is_batch)
      end

    DatabaseUtils.safe_call(fn -> Repo.all(query) end)
  end

  @spec insert(Webhook.t()) :: {:ok, Webhook.t() | DatabaseUtils.database_error()}
  def insert(webhook) do
    DatabaseUtils.safe_call(fn -> Repo.insert!(webhook) end)
  end
end
