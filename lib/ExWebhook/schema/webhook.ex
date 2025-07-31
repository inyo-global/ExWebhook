defmodule ExWebhook.Schema.Webhook do
  use TypedEctoSchema
  import Ecto.Changeset

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  @foreign_key_type Ecto.UUID

  typed_schema "webhook" do
    @moduledoc "Webhook struct"
    @typedoc "Webhook struct"
    field(:tenant_id, :string)
    field(:url, :string)
    field(:is_batch, :boolean)
    has_many :webhook_types, ExWebhook.Schema.WebhookType

    timestamps(inserted_at: :created_at, updated_at: false)
  end

  def changeset(webhook, attrs) do
    webhook
    |> cast(attrs, [:tenant_id, :url, :is_batch])
    |> validate_required([:tenant_id, :url])
  end
end
