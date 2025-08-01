defmodule ExWebhook.Repo.Migrations.RenameWebhookTypesTableToWebhookEvents do
  use Ecto.Migration

  def change do
    drop unique_index(:webhook_types, [:webhook_id, :type_name])

    rename table(:webhook_types), to: table(:webhook_events)
    rename table(:webhook_events), :type_name, to: :event_name

    create unique_index(:webhook_events, [:webhook_id, :event_name])
  end
end
