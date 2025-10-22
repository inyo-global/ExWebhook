import Config

config :webhook, :ecto_repos, [ExWebhook.Repo]

config :webhook, ExWebhook.Web.Endpoint,
  http: [ip: {0, 0, 0, 0}, port: 4000],
  adapter: Bandit.PhoenixAdapter,
  url: [host: "localhost", port: 4000],
  server: true

import_config "#{config_env()}.exs"
