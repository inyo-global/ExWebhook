defmodule ExWebhook.Schema.Webhook do
  @moduledoc """
  Represents a webhook.

  This schema defines the main properties of a webhook, like its URL and tenant.
  """
  use TypedEctoSchema
  import Ecto.Changeset

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  @foreign_key_type Ecto.UUID

  typed_schema "webhook" do
    @typedoc "Webhook struct"
    field(:tenant_id, :string)
    field(:url, :string)
    field(:is_batch, :boolean)
    has_many(:webhook_events, ExWebhook.Schema.WebhookEvent)

    field(:deactivated, :boolean, default: false)
    field(:deactivated_at, :utc_datetime)
    field(:deactivated_by, :string)

    timestamps(inserted_at: :created_at, updated_at: false)
  end

  def changeset(webhook, attrs) do
    webhook
    |> cast(attrs, [:tenant_id, :url, :is_batch])
    |> validate_required([:tenant_id, :url])
  end

  def deactivate_changeset(webhook, deactivated_by_name) do
    deactivated_at =
      DateTime.utc_now()
      |> DateTime.truncate(:second)

    webhook
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.put_change(:deactivated, true)
    |> Ecto.Changeset.put_change(:deactivated_at, deactivated_at)
    |> Ecto.Changeset.put_change(:deactivated_by, deactivated_by_name)
    |> Ecto.Changeset.validate_required([:deactivated, :deactivated_at, :deactivated_by])
  end
end
