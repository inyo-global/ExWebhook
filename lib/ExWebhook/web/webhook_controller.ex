defmodule ExWebhook.Web.WebhookController do
  @moduledoc """
  Webhook controller
  """
  use ExWebhook.Web, :controller
  alias ExWebhook.Schema.Webhook, as: WebhookSchema
  alias ExWebhook.Schema.WebhookType, as: WebhookTypeSchema
  alias ExWebhook.WebhookRepository
  require Logger

  def index(conn, %{"tenant" => tenant_id}) do
    case WebhookRepository.list_webhooks(tenant_id, nil) do
      {:ok, webhooks} ->
        formatted_webhooks =
          Enum.map(webhooks, fn webhook ->
            %{
              id: webhook.id,
              tenantId: webhook.tenant_id,
              url: webhook.url,
              isBatch: webhook.is_batch,
              types: Enum.map(webhook.webhook_types, fn wt -> wt.type_name end),
              createdAt: webhook.created_at
            }
          end)

        json(conn, %{webhooks: formatted_webhooks})

      {:connection_error, error} ->
        Logger.error("Connection error while listing webhooks: #{inspect(error)}")

        conn
        |> put_status(:internal_server_error)
        |> json(%{error: "Internal server error"})

      {:unexpected_error, error} ->
        Logger.error("Unexpected error while listing webhooks: #{inspect(error)}")

        conn
        |> put_status(:internal_server_error)
        |> json(%{error: "Internal server error"})
    end
  end

  def new(conn, %{"tenant" => tenant}) do
    case conn.body_params do
      %{"url" => url, "isBatch" => is_batch, "types" => types} ->
        case create_webhook(%{
               "url" => url,
               "isBatch" => is_batch,
               "tenant" => tenant,
               "types" => types
             }) do
          {:ok, entity} ->
            formatted_types = Enum.map(entity.webhook_types, fn wt -> wt.type_name end)

            conn
            |> put_status(:created)
            |> json(%{
              id: entity.id,
              isBatch: entity.is_batch,
              url: entity.url,
              types: formatted_types
            })

          {http_error, error_message} ->
            conn
            |> put_status(http_error)
            |> json(%{error: error_message})
        end

      _ ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: "Invalid parameters"})
    end
  end

  defp create_webhook(%{
         "url" => url,
         "isBatch" => is_batch,
         "tenant" => tenant,
         "types" => types
       }) do
    uri = URI.parse(url)

    case {uri.scheme, uri.host} do
      {nil, _} ->
        {:bad_request, "Invalid URL"}

      {_, nil} ->
        {:bad_request, "Invalid URL"}

      {"https", _} ->
        case create_webhook_with_types(
               %{
                 "url" => url,
                 "is_batch" => is_batch,
                 "tenant_id" => tenant
               },
               types
             ) do
          {:ok, entity} ->
            {:ok, entity}

          {:error, error} ->
            Logger.error(
              "Error creating webhook from create_webhook_with_types: #{inspect(error)}"
            )

            {:internal_server_error, error}
        end

      {schema, _} ->
        {:bad_request, "#{schema} is invalid, url must have a https schema"}
    end
  end

  defp create_webhook_with_types(webhook_params, type_names) do
    webhook_type_attrs = Enum.map(type_names, fn name -> %{type_name: name} end)

    webhook_changeset =
      %WebhookSchema{}
      |> WebhookSchema.changeset(webhook_params)

    webhook_changeset =
      webhook_changeset
      |> Ecto.Changeset.cast_assoc(:webhook_types,
        with: &WebhookTypeSchema.changeset/2,
        required: false
      )

    final_changeset =
      webhook_changeset
      |> Ecto.Changeset.put_assoc(:webhook_types, webhook_type_attrs)

    case ExWebhook.Repo.insert(final_changeset) do
      {:ok, entity} ->
        {:ok, ExWebhook.Repo.preload(entity, :webhook_types)}

      {:error, error} ->
        Logger.error("Error creating webhook (unexpected): #{inspect(error)}")
        {:error, "Internal server error"}
    end
  end
end
