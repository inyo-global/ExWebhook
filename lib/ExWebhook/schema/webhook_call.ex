defmodule ExWebhook.Schema.WebhookCall do
  @moduledoc """
  Represents a record of a webhook execution.

  This schema stores the request and response details of a webhook call.
  """
  use TypedEctoSchema

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  @foreign_key_type Ecto.UUID

  typed_schema "webhook_call" do
    @typedoc "Webhook struct"
    field(:success, :boolean, enforce: true, null: false)
    field(:response_status, :integer)
    field(:response_body, :string)
    field(:request_body, :string)
    field(:error, :string)
    belongs_to(:webhook, ExWebhook.Schema.Webhook)

    timestamps(inserted_at: :created_at, updated_at: false)
  end
end
