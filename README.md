# ExWebhook

ExWebhook transforms messages from a Broadway producer (Kafka, SQS, Google Pub/Sub, etc.) into webhooks.

## Features
- Tenant Aware: Each webhook is tied to a `tenantId`, and every message should have a `tenantId` field to determine which webhook to call.
- Batch messages in a single webhook call: as JSONLine webhooks (optional).

## Running
The easiest way to get started with ExWebhook is by using Docker. There's a SQS Docker Compose example in the sample/sqs directory using LocalStack.

## Sample Configuration
The runtime.exs file is configured as:

### Batch Processor

```
config :webhook, :batch_processor_options,
  producer_module: BroadwaySQS.Producer,
  producer_options: [
    queue_url: "http://localstack:4566/000000000000/sqs-batch",
    config: [
      scheme: "http://",
      host: "localstack",
      port: 4566,
      access_key_id: "",
      secret_access_key: ""
    ]
  ],
  batch_size: 3,
  batch_timeout: 3_000
```

### Single Processor

```
config :webhook, :single_processor_options,
  producer_module: BroadwaySQS.Producer,
  producer_options: [
    queue_url: "http://localstack:4566/000000000000/sqs-single",
    config: [
      scheme: "http://",
      host: "localstack",
      port: 4566,
      access_key_id: "",
      secret_access_key: ""
    ]
  ]
```

## Execution
Just start the docker using `docker compose up`and execute the `run.sh` script, which emits messages and executes the webhook. You can check the webhook call status using the database.