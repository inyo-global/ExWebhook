defmodule ExWebhook.Repo.Migrations.V1 do
  use Ecto.Migration

  def change do
    create_if_not_exists table(:webhook, primary_key: false) do
      add :id, :uuid, primary_key: true, null: false
      add :tenant_id, :string, null: false
      add :is_batch, :boolean, null: false
      add :url, :string, null: false

      timestamps(inserted_at: :created_at, updated_at: false)
    end

    create_if_not_exists table(:webhook_call, primary_key: false) do
      add :id, :uuid, primary_key: true, null: false
      add :success, :boolean, null: false
      add :response_status, :int4, null: true
      add :response_body, :text, null: true
      add :request_body, :text,  null: true
      add :error, :string, null: true

      add :webhook_id, references(:webhook, type: :uuid)

      timestamps(inserted_at: :created_at, updated_at: false)
    end
  end
end
