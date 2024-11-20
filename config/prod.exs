import Config

config :logger,
  level: :info,
  backends: [:console],
  compile_time_purge_matching: [
    [level_lower_than: :debug]
  ]
