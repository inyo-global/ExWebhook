defmodule ExWebhook.Web.Router do
  use ExWebhook.Web, :router

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/organizations/:tenant", ExWebhook.Web do
    pipe_through(:api)

    post("/webhooks", WebhookController, :new)
  end
end
