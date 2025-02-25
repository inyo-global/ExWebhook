import Config

config :webhook, :ecto_repos, [ExWebhook.Repo]

config :webhook, :batch_producer_options,
  producer_module: BroadwayKafka.Producer,
  producer_options: [
    hosts:
      System.get_env("KAFKA_URL") || "my-cluster-kafka-bootstrap.kafka.svc.cluster.local:9092",
    group_id: "ex_webhook",
    topics: ["batchTransactionProcessedEvents"],
    # 2024-11-15
    offset_reset_policy: {:timestamp, 1_731_542_400_000}
  ],
  batch_size: 1000,
  batch_timeout: 60_000

config :webhook, :single_producer_options,
  producer_module: BroadwayKafka.Producer,
  producer_options: [
    hosts:
      System.get_env("KAFKA_URL") || "my-cluster-kafka-bootstrap.kafka.svc.cluster.local:9092",
    group_id: "webhook",
    topics: ["documentUpdatedEvents"]
  ]

import_config "#{config_env()}.exs"
