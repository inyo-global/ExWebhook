import Config

config :webhook, :ecto_repos, [ExWebhook.Repo]

config :webhook, ExWebhook.Web.Endpoint,
  http: [ip: {0, 0, 0, 0}, port: 4000],
  adapter: Bandit.PhoenixAdapter,
  url: [host: "localhost", port: 4000],
  server: true

config :webhook, :phoenix_swagger,
  swagger_files: %{
    "priv/static/swagger.json" => [
      router: ExWebhook.Web.Router,
      endpoint: ExWebhook.Web.Endpoint
    ]
  }

import_config "#{config_env()}.exs"
