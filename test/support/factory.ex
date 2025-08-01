defmodule ExWebhook.Factory do
  @moduledoc false
  alias ExWebhook.Repo
  alias ExWebhook.Schema.Webhook
  alias ExWebhook.Schema.WebhookEvent

  def build(:webhook) do
    %Webhook{
      id: UUID.uuid4(),
      url: "https://postman-echo.com/post",
      tenant_id: UUID.uuid4(),
      is_batch: true
    }
  end

  def build(:webhook, attrs, events_names \\ []) do
    webhook = build(:webhook) |> struct!(attrs)

    webhook_events =
      Enum.map(events_names, fn name ->
        %WebhookEvent{event_name: name}
      end)

    %{webhook | webhook_events: webhook_events}
  end

  def insert!(:webhook, attrs \\ [], events_names \\ []) do
    webhook = build(:webhook, attrs, events_names)
    Repo.insert!(webhook)
  end
end
