defmodule ExWebhook.Repo.Migrations.AddWebhookDeleteFields do
  use Ecto.Migration

  def change do
    alter table(:webhook) do
      add :deactivated, :boolean, default: false
      add :deactivated_at, :utc_datetime
      add :deactivated_by, :text
    end
  end
end
