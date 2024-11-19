import Config

config :webhook, ExWebhook.Repo,
  username: "root",
  url: "postgresql://localhost:55848/defaultdb"

config :webhook,
  producer_module: Broadway.DummyProducer,
  producer_options: [
    hosts: [localhost: 32778],
    group_id: "ex_webhook",
    topics: ["batchTransactionProcessedEvents"]
  ],
  batch_size: 5,
  batch_timeout: 100
