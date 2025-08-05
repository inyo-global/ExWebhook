defmodule ExWebhook.Web.Router do
  use ExWebhook.Web, :router

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/organizations/:tenant", ExWebhook.Web do
    pipe_through(:api)

    post("/webhooks", WebhookController, :new)
    get("/webhooks", WebhookController, :index)
    delete("/webhooks/:id", WebhookController, :delete)
  end

  scope "/q/openapi" do
    forward("/", PhoenixSwagger.Plug.SwaggerUI, otp_app: :webhook, swagger_file: "swagger.json")
  end

  def swagger_info do
    %{
      info: %{
        version: "1.0.0",
        title: "Webhook API"
      }
    }
  end
end
