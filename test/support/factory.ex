defmodule ExWebhook.Factory do
  @moduledoc false
  alias ExWebhook.Repo
  alias ExWebhook.Schema.Webhook

  def build(:webhook) do
    %Webhook{
      id: UUID.uuid4(),
      url: "https://postman-echo.com/post",
      tenant_id: UUID.uuid4(),
      is_batch: true
    }
  end

  def build(factory_name, attributes) do
    factory_name |> build() |> struct!(attributes)
  end

  def insert!(factory_name, attributes \\ []) do
    factory_name |> build(attributes) |> Repo.insert!()
  end
end
