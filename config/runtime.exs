import Config

config :webhook, ExWebhook.Repo,
  username: System.get_env("DATASOURCE_USERNAME") || "postgres",
  password: System.get_env("DATASOURCE_PASSWORD") || "postgres",
  url: System.get_env("DATASOURCE_URL") || "ecto://localhost/postgres"
