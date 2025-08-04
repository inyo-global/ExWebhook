defmodule ExWebhook.Repo.Migrations.AddWebhookDeleteFields do
  use Ecto.Migration

  def change do
    alter table(:webhook) do
      add :deactivated_at, :utc_datetime
    end
  end
end
