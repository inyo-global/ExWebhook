import Config

config :webhook, ExWebhook.Repo,
  username: System.get_env("QUARKUS_DATASOURCE_USERNAME"),
  password: System.get_env("QUARKUS_DATASOURCE_PASSWORD"),
  url: System.get_env("QUARKUS_DATASOURCE_REACTIVE_URL")
