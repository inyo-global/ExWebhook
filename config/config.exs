import Config

config :webhook, :ecto_repos, [ExWebhook.Repo]

config :webhook,
  producer_module: BroadwayKafka.Producer,
  producer_options: [
    hosts: [localhost: 32794],
    group_id: "ex_webhook",
    topics: ["batchTransactionProcessedEvents"],
    offset_reset_policy: :earliest
  ],
  batch_size: 1000,
  batch_timeout: 60_000

import_config "#{config_env()}.exs"
