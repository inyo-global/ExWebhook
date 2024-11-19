defmodule ExWebhook.WebhookRepository do
  @moduledoc """
  Webhook Repository
  """
  import Ecto.Query
  alias ExWebhook.DatabaseUtils
  alias ExWebhook.Repo
  alias ExWebhook.Schema.Webhook

  @spec list_webhooks(binary(), boolean()) ::
          {:ok, [Webhook.t()]} | DatabaseUtils.database_error()
  def list_webhooks(tenant, is_batch) do
    query =
      from(w in Webhook,
        where: [tenant_id: ^tenant, is_batch: ^is_batch],
        select: w
      )

    DatabaseUtils.safe_call(fn -> Repo.all(query) end)
  end

  @spec insert(Webhook.t()) :: {:ok, Webhook.t() | DatabaseUtils.database_error()}
  def insert(webhook) do
    DatabaseUtils.safe_call(fn -> Repo.insert!(webhook) end)
  end
end
