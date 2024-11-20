import Config

config :logger,
  level: :debug,
  backends: [:console],
  compile_time_purge_matching: [
    [level_lower_than: :debug]
  ]

config :webhook,
  producer_module: Broadway.DummyProducer,
  producer_options: [
    hosts: [localhost: 32778],
    group_id: "ex_webhook",
    topics: ["batchTransactionProcessedEvents"]
  ],
  batch_size: 5,
  batch_timeout: 100
