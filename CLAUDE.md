# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Dependencies
mix deps.get

# Code quality (run in this order, matching CI)
mix format --check-formatted
mix credo --strict
mix dialyzer

# Database
mix ecto.migrate

# Tests
mix test                                      # All tests
mix test test/webhook_executor_test.exs       # Single file
mix test test/webhook_executor_test.exs:42    # Specific line
mix test --trace                              # Verbose output

# Auto-format
mix format
```

CI runs: `format → credo --strict → dialyzer → ecto.migrate → test`

## Architecture

ExWebhook is a message transformation service that reads from Broadway producers (Kafka, SQS, Google Pub/Sub) and forwards messages as HTTP webhook calls to tenant-configured URLs.

### Supervision Tree

```
Application
├── BatchProcessor  (WebhookBatchProcessor) — groups messages by tenantId, sends as JSONLines
├── SingleProcessor (WebhookSingleProcessor) — sends individual messages as JSON
├── TcpHealthCheck  — health check on port 4321
└── Web.Endpoint    — Phoenix HTTP server on port 4000
```

### Message Flow

1. Message arrives via Broadway producer
2. Processor decodes JSON and extracts `tenantId`
3. `WebhookExecutor` queries active webhooks for that tenant from the DB
4. Webhooks are filtered by subscribed event names (if any)
5. HTTP POST is made to each webhook URL — batch as JSONLines, single as JSON
6. Result (success/failure, status, body) saved to `webhook_call` table

### Key Modules

| Module | Role |
|--------|------|
| `ExWebhook.WebhookExecutor` | Core HTTP dispatch + result persistence |
| `ExWebhook.BatchProcessor` | Broadway batch pipeline |
| `ExWebhook.SingleProcessor` | Broadway single-message pipeline |
| `ExWebhook.WebhookRepository` | DB queries for webhook configs |
| `ExWebhook.WebhookCallRepository` | DB queries for call history |
| `ExWebhook.Web.WebhookController` | REST API (create/list/deactivate) |
| `ExWebhook.Web.ApiSpec` | OpenAPI spec via Oaskit |

### API Endpoints

```
GET    /organizations/:tenant/webhooks        — List webhooks
POST   /organizations/:tenant/webhooks        — Create webhook
DELETE /organizations/:tenant/webhooks/:id    — Deactivate webhook
GET    /q/openapi                             — OpenAPI spec
```

### Database Schema

- **webhook** — webhook configurations (tenant_id, url, is_batch, deactivated_at)
- **webhook_call** — execution history (success, response_status, response_body, error)
- **webhook_events** — event name subscriptions per webhook

### Configuration

The Broadway producer is swapped per environment via config:
- `dev`/`test`: `DummyProducer`
- `prod`: real Kafka/SQS producers via env vars

Runtime DB connection uses env vars: `DATASOURCE_USERNAME`, `DATASOURCE_PASSWORD`, `DATASOURCE_URL`.

### Tests

Test factories live in `test/support/factory.ex`:
- `Factory.insert!(:webhook)` — creates and persists a webhook
- `Factory.build(:webhook, attrs, event_names)` — builds in-memory
