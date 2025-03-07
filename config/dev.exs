import Config

config :logger,
  level: :debug,
  backends: [:console],
  compile_time_purge_matching: [
    [level_lower_than: :debug]
  ]

config :webhook, ExWebhook.Repo,
  username: System.get_env("DATASOURCE_USERNAME") || "postgres",
  password: System.get_env("DATASOURCE_PASSWORD") || "postgres",
  url: "ecto://localhost/postgres"

config :webhook, :batch_processor_options,
  producer_module: Broadway.DummyProducer,
  producer_options: [
    hosts: [localhost: 32778],
    group_id: "ex_webhook",
    topics: ["batchTransactionProcessedEvents"]
  ],
  batch_size: 5,
  batch_timeout: 100

config :webhook, :single_processor_options,
  producer_module: Broadway.DummyProducer,
  producer_options: [
    hosts: [localhost: 32778],
    group_id: "webhook",
    topics: ["documentUpdatedEvents"]
  ]
