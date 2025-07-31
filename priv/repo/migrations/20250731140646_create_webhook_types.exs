defmodule ExWebhook.Repo.Migrations.CreateWebhookTypes do
  use Ecto.Migration

  def change do
    create_if_not_exists table(:webhook_types, primary_key: false) do
      add :id, :uuid, primary_key: true, null: false
      add :type_name, :text, null: false
      add :webhook_id, references(:webhook, type: :uuid)

      timestamps(inserted_at: :created_at, updated_at: false)
    end

    create unique_index(:webhook_types, [:webhook_id, :type_name])
  end
end
