defmodule ExWebhook.Web.Router do
  use ExWebhook.Web, :router

  pipeline :api do
    plug(:accepts, ["json"])
    plug(PrincipalDataPlug)
  end

  scope "/organizations/:tenant", ExWebhook.Web do
    pipe_through(:api)

    post("/webhooks", WebhookController, :new)
    get("/webhooks", WebhookController, :index)
    delete("/webhooks/:id", WebhookController, :delete)
  end
end
