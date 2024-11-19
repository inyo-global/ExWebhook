defmodule ExWebhook.Repo.Migrations.V1 do
  use Ecto.Migration

  def change do
    create_if_not_exists table(:webhook) do
      add :id, :uuid, primary_key: true, null: false
      add :tenant_id, :string, null: false, null: false
      add :is_batch, :string, null: false, null: false
      add :url, :string, null: false, null: false

      timestamps(inserted_at: :created_at)
    end

    create_if_not_exists table(:webhook_call) do
      add :id, :uuid, primary_key: true, null: false
      add :tenant_id, :boolean, null: false, null: false
      add :success, :string, null: false, null: false, default: false
      add :response_status, :int4, null: false, null: true
      add :response_body, :text, null: false, null: true
      add :request_body, :text, null: false, null: true
      add :error, :string, null: false, null: false

      add :webhook_id, references(:webhook)

      timestamps(inserted_at: :created_at)
    end
  end
end
