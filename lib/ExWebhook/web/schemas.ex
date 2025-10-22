defmodule ExWebhook.Web.Schemas do
  @moduledoc """
  Schemas apidocs
  """
  use JSV.Schema

  defmodule Webhook do
    @moduledoc """
    Webhook apidocs schema
    """
    defschema(%{
      title: "Webhook",
      description: "A registered webhook.",
      type: :object,
      properties: %{
        id: %{type: :string, description: "The unique identifier of the webhook"},
        url: %{type: :string, description: "The URL for the webhook"},
        isBatch: %{type: :boolean, description: "Indicates if events are batched"},
        events: %{
          type: :array,
          description: "A list of event names to subscribe to.",
          items: %{type: :string}
        },
        createdAt: %{
          type: :string,
          description: "The creation timestamp",
          format: :"date-time"
        }
      },
      additionalProperties: false,
      example: %{
        "id" => "5bec2748-d5fe-47bb-84ff-961ddee86c12",
        "url" => "http://localhost:8080/inyo/webhooks",
        "isBatch" => false
      }
    })
  end

  defmodule WebhookRequest do
    @moduledoc """
    WebhookRequest apidocs schema
    """
    defschema(%{
      title: "WebhookRequest",
      description: "The input parameters for creating a new webhook.",
      type: :object,
      properties: %{
        url: %{type: :string, description: "The URL to send webhook events to."},
        isBatch: %{type: :boolean, description: "Indicates if events should be sent in a batch."},
        events: %{
          type: :array,
          description: "A list of event names to subscribe to.",
          items: %{type: :string}
        }
      },
      additionalProperties: false,
      example: %{
        "url" => "http://localhost:8080/test/webhooks/agents",
        "events" => ["documentUpdatedEvents", "agentUpdatedEvents"]
      }
    })
  end

  defmodule WebhookList do
    @moduledoc """
    WebhookList apidocs schema
    """
    defschema(%{
      title: "WebhookList",
      description: "A list of webhooks.",
      type: :object,
      properties: %{
        webhooks: %{type: :array, description: "The list of webhooks.", items: Webhook}
      },
      additionalProperties: false,
      example: %{
        "webhooks" => [
          %{
            "id" => "5bec2748-d5fe-47bb-84ff-961ddee86c12",
            "url" => "http://localhost:8080/test/webhooks/agents",
            "isBatch" => false,
            "events" => ["documentUpdatedEvents", "agentUpdatedEvents"],
            "createdAt" => "2025-03-07T13:21:29"
          },
          %{
            "id" => "59f2c6f9-a476-4666-9c53-0c148d952c39",
            "url" => "http://localhost:8080/test/webhooks/batch",
            "isBatch" => true,
            "events" => ["batchTransactionProcessedEvents"],
            "createdAt" => "2025-08-04T18:25:07"
          }
        ]
      }
    })
  end
end
