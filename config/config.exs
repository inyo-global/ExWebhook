import Config

config :webhook, :ecto_repos, [ExWebhook.Repo]

config :webhook, ExWebhook.Web.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4000],
  adapter: Bandit.PhoenixAdapter,
  url: [host: "localhost", port: 4000]

import_config "#{config_env()}.exs"
