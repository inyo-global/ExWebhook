defmodule ExWebhook.Factory do
  @moduledoc false
  alias ExWebhook.Repo
  alias ExWebhook.Schema.Webhook
  alias ExWebhook.Schema.WebhookType

  def build(:webhook) do
    %Webhook{
      id: UUID.uuid4(),
      url: "https://postman-echo.com/post",
      tenant_id: UUID.uuid4(),
      is_batch: true
    }
  end

  def build(:webhook, attrs, types_names \\ []) do
    webhook = build(:webhook) |> struct!(attrs)

    webhook_types =
      Enum.map(types_names, fn name ->
        %WebhookType{type_name: name}
      end)

    %{webhook | webhook_types: webhook_types}
  end

  def insert!(:webhook, attrs \\ [], types_names \\ []) do
    webhook = build(:webhook, attrs, types_names)
    Repo.insert!(webhook)
  end
end
