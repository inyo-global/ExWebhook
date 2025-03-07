defmodule ExWebhook.Web.Endpoint do
  use Phoenix.Endpoint, otp_app: :webhook

  plug(Plug.Parsers,
    parsers: [:urlencoded, :json],
    pass: ["*/*"],
    json_decoder: Jason
  )

  plug(ExWebhook.Web.Router)
end
