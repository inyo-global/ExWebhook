defmodule ExWebhook.Web.ApiSpec do
  @moduledoc """
  For generate apidocs
  """
  alias Oaskit.Spec.Paths
  alias Oaskit.Spec.Server
  alias ExWebhook.Web.{Endpoint, Router}
  use Oaskit

  @impl true
  def spec do
    %{
      openapi: "3.1.0",
      info: %{
        title: "Webhook API",
        version: "1.0.0"
      },
      servers: [Server.from_config(:webhook, Endpoint)],
      paths: Paths.from_router(Router)
    }
  end
end
