import Config

config :webhook, ExWebhook.Repo,
  username: System.get_env("DATASOURCE_USERNAME") || "postgres",
  password: System.get_env("DATASOURCE_PASSWORD") || "postgres",
  url: "ecto://postgres/postgres"


config :webhook, :batch_processor_options,
  producer_module: BroadwaySQS.Producer,
  producer_options: [
    queue_url: "http://localstack:4566/000000000000/sqs-demo",
    config: [
    scheme: "http://",
    host: "localstack",
    port: 4566,
    access_key_id: "",
    secret_access_key: ""
    ]
  ],
  batch_size: 2,
  batch_timeout: 1

config :webhook, :single_processor_options,
  producer_module: BroadwaySQS.Producer,
  producer_options: [
    queue_url: "http://localstack:4566/000000000000/sqs-demo",
    config: [
    scheme: "http://",
    host: "localstack",
    port: 4566,
    access_key_id: "",
    secret_access_key: ""
    ]
  ]
