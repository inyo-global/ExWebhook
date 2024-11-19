defmodule ExWebhook.Schema.Webhook do
  use TypedEctoSchema

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  @foreign_key_type Ecto.UUID

  typed_schema "webhook" do
    @moduledoc "Webhook struct"
    @typedoc "Webhook struct"
    field(:tenant_id, :string)
    field(:url, :string)
    field(:is_batch, :boolean)

    timestamps(inserted_at: :created_at, updated_at: false)
  end
end
