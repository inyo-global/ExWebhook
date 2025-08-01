defmodule ExWebhook.Schema.WebhookEvent do
  @moduledoc """
  Represents a webhook event.

  This schema is used to define the events a webhook can be subscribed to.
  """
  use TypedEctoSchema
  import Ecto.Changeset

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  @foreign_key_type Ecto.UUID

  typed_schema "webhook_events" do
    @typedoc "WebhookEvent struct"
    field(:event_name, :string)
    belongs_to(:webhook, ExWebhook.Schema.Webhook)

    timestamps(inserted_at: :created_at, updated_at: false)
  end

  def changeset(webhook_events, attrs) do
    webhook_events
    |> cast(attrs, [:event_name, :webhook_id])
    |> validate_required([:event_name, :webhook_id])
  end
end
