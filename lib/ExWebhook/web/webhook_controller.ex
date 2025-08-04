defmodule ExWebhook.Web.WebhookController do
  @moduledoc """
  Webhook controller
  """
  use ExWebhook.Web, :controller
  alias ExWebhook.Schema.Webhook, as: WebhookSchema
  alias ExWebhook.Schema.WebhookEvent, as: WebhookEventSchema
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
              events: Enum.map(webhook.webhook_events, fn wt -> wt.event_name end),
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
    with {:ok, params} <- validate_webhook_params(conn.body_params),
         {:ok, entity} <- create_webhook(Map.put(params, "tenant", tenant)) do
      conn
      |> put_status(:created)
      |> json(%{
        id: entity.id,
        isBatch: entity.is_batch,
        url: entity.url,
        events: Enum.map(entity.webhook_events, fn wt -> wt.event_name end)
      })
    else
      {:error, error_message} ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: error_message})

      {http_error, error_message} ->
        conn
        |> put_status(http_error)
        |> json(%{error: error_message})
    end
  end

  def delete(conn, %{"tenant" => tenant_id, "id" => webhook_id}) do
    case ExWebhook.Repo.get_by(WebhookSchema, id: webhook_id, tenant_id: tenant_id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Webhook with #{webhook_id} not found"})

      webhook ->
        principal_data = conn.assigns[:principal_data]
        changeset = WebhookSchema.deactivate_changeset(webhook, principal_data.preferred_username)

        case WebhookRepository.update(changeset) do
          {:ok, _webhook} ->
            conn
            |> send_resp(:no_content, "")

          {:connection_error, error} ->
            Logger.error("Connection error while deactivating webhook: #{inspect(error)}")

            conn
            |> put_status(:internal_server_error)
            |> json(%{error: "Internal server error"})

          {:unexpected_error, error} ->
            Logger.error("Unexpected error while deactivating webhook: #{inspect(error)}")

            conn
            |> put_status(:internal_server_error)
            |> json(%{error: "Internal server error"})
        end
    end
  end

  defp validate_webhook_params(params = %{"url" => url}) do
    events = Map.get(params, "events", [])

    if not is_list(events) or not Enum.all?(events, &is_binary/1) do
      {:error, "Events must be a list of strings."}
    else
      is_batch = Map.get(params, "isBatch", false)
      {:ok, %{"url" => url, "isBatch" => is_batch, "events" => events}}
    end
  end

  defp validate_webhook_params(_) do
    {:error, "Invalid parameters."}
  end

  defp create_webhook(%{
         "url" => url,
         "isBatch" => is_batch,
         "tenant" => tenant,
         "events" => events
       }) do
    uri = URI.parse(url)

    case {uri.scheme, uri.host} do
      {nil, _} ->
        {:bad_request, "Invalid URL"}

      {_, nil} ->
        {:bad_request, "Invalid URL"}

      {"https", _} ->
        case create_webhook_with_events(
               %{
                 "url" => url,
                 "is_batch" => is_batch,
                 "tenant_id" => tenant
               },
               events
             ) do
          {:ok, entity} ->
            {:ok, entity}

          {:error, error} ->
            Logger.error(
              "Error creating webhook from create_webhook_with_events: #{inspect(error)}"
            )

            {:internal_server_error, error}
        end

      {schema, _} ->
        {:bad_request, "#{schema} is invalid, url must have a https schema"}
    end
  end

  defp create_webhook_with_events(webhook_params, event_names) do
    webhook_event_attrs = Enum.map(event_names, fn name -> %{event_name: name} end)

    webhook_changeset =
      %WebhookSchema{}
      |> WebhookSchema.changeset(webhook_params)

    webhook_changeset =
      webhook_changeset
      |> Ecto.Changeset.cast_assoc(:webhook_events,
        with: &WebhookEventSchema.changeset/2,
        required: false
      )

    final_changeset =
      webhook_changeset
      |> Ecto.Changeset.put_assoc(:webhook_events, webhook_event_attrs)

    case WebhookRepository.insert(final_changeset) do
      {:ok, entity} ->
        {:ok, ExWebhook.Repo.preload(entity, :webhook_events)}

      {:connection_error, error} ->
        Logger.error("Connection error while inserting webhook: #{inspect(error)}")
        {:error, "Internal server error"}

      {:unexpected_error, error} ->
        Logger.error("Unexpected error while inserting webhook: #{inspect(error)}")
        {:error, "Internal server error"}
    end
  end
end
