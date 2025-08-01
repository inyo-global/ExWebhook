defmodule ExWebhook.Schema.WebhookType do
  @moduledoc """
  Represents a webhook type.

  This schema is used to define the types of events a webhook can be subscribed to.
  """
  use TypedEctoSchema
  import Ecto.Changeset

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  @foreign_key_type Ecto.UUID

  typed_schema "webhook_types" do
    @typedoc "Webhook struct"
    field(:type_name, :string)
    belongs_to(:webhook, ExWebhook.Schema.Webhook)

    timestamps(inserted_at: :created_at, updated_at: false)
  end

  def changeset(webhook_types, attrs) do
    webhook_types
    |> cast(attrs, [:type_name, :webhook_id])
    |> validate_required([:type_name, :webhook_id])
  end
end
