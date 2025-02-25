import Config

config :webhook, :ecto_repos, [ExWebhook.Repo]

import_config "#{config_env()}.exs"
