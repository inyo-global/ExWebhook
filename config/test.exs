import Config

config :webhook, ExWebhook.Repo,
  username: System.get_env("DB_USER") || "postgres",
  password: System.get_env("DB_PASSWORD") || "postgres",
  hostname: System.get_env("DB_HOST") || "localhost",
  port: System.get_env("DB_PORT") || "5432",
  database: "postgres"

config :webhook,
  producer_module: Broadway.DummyProducer,
  producer_options: [
    hosts: [localhost: 32778],
    group_id: "ex_webhook",
    topics: ["batchTransactionProcessedEvents"]
  ],
  batch_size: 5,
  batch_timeout: 100
