defmodule ExWebhook.Web.WebhookController do
  @moduledoc """
  Webhook controller
  """
  use ExWebhook.Web, :controller
  alias ExWebhook.Schema.Webhook, as: WebhookSchema
  require Logger

  def new(conn, %{"tenant" => tenant}) do
    case conn.body_params do
      %{"url" => url, "isBatch" => is_batch} ->
        case create_webhook(%{"url" => url, "isBatch" => is_batch, "tenant" => tenant}) do
          {:ok, entity} ->
            conn
            |> put_status(:created)
            |> json(%{id: entity.id, isBatch: entity.is_batch, url: entity.url})

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

  defp create_webhook(%{"url" => url, "isBatch" => is_batch, "tenant" => tenant}) do
    uri = URI.parse(url)

    case {uri.scheme, uri.host} do
      {nil, _} ->
        {:bad_request, "Invalid URL"}

      {_, nil} ->
        {:bad_request, "Invalid URL"}

      {"https", _} ->
        case %WebhookSchema{}
             |> WebhookSchema.changeset(%{
               "url" => url,
               "is_batch" => is_batch,
               "tenant_id" => tenant
             })
             |> ExWebhook.Repo.insert() do
          {:ok, entity} ->
            {:ok, entity}

          {:error, error} ->
            Logger.error("Error creating webhook: #{inspect(error)}")

            {:internal_server_error, "Internal server error"}
        end

      {schema, _} ->
        {:bad_request, "#{schema} is invalid, url must have a https schema"}
    end
  end
end
