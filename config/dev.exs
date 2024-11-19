import Config

config :webhook, ExWebhook.Repo,
  username: "root",
  url: "postgresql://localhost:55848/defaultdb"
