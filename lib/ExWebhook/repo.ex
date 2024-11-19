defmodule ExWebhook.Repo do
  use Ecto.Repo,
    otp_app: :webhook,
    adapter: Ecto.Adapters.Postgres
end
