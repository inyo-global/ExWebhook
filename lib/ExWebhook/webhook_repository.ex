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
        where: w.tenant_id == ^tenant and w.deactivated == false,
        preload: [:webhook_events],
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

  @spec insert(Ecto.Changeset.t()) :: {:ok, Webhook.t()} | DatabaseUtils.database_error()
  def insert(changeset) do
    DatabaseUtils.safe_call(fn -> Repo.insert!(changeset) end)
  end

  @spec update(Ecto.Changeset.t()) :: {:ok, Webhook.t()} | DatabaseUtils.database_error()
  def update(changeset) do
    DatabaseUtils.safe_call(fn -> Repo.update!(changeset) end)
  end
end
