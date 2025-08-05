defmodule ExWebhook.MixProject do
  use Mix.Project

  def project do
    [
      app: :webhook,
      version: "0.1.0",
      elixir: "~> 1.17",
      env: [webhook: []],
      config_path: "config/config.exs",
      start_permanent: Mix.env() == :prod,
      elixirc_paths: elixirc_paths(Mix.env()),
      deps: deps(),
      releases: [
        webhook: [
          include_executables_for: [:unix],
          applications: [runtime_tools: :permanent]
        ]
      ],
      dialyzer: [
        plt_add_apps: [:phoenix_swagger]
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {ExWebhook.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:brod,
      #  override: true,
      #  git: "https://github.com/inyo-global/brod",
      #  ref: "bbbffad17fc9d3b7da3ed01b63a1d3c7cd087653"},
      # {:kafka_protocol, "~> 4.2"},
      {:brod, "~> 4.4.5"},
      {:broadway, "~> 1.2.1"},
      {:broadway_kafka, "~> 0.4.4"},
      {:broadway_sqs, "~> 0.7.4"},
      {:jason, "~> 1.4"},
      {:uuid, "~> 1.1"},
      {:ecto_sql, "~> 3.12"},
      {:postgrex, "~> 0.15"},
      {:httpoison, "~> 2.2.1"},
      {:tcp_health_check, "~> 0.1.0"},
      {:phoenix, "~> 1.7"},
      {:bandit, "~> 1.5"},
      {:typed_ecto_schema, "~> 0.4.1", runtime: false},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.34", only: :dev, runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      {:phoenix_swagger, "~> 0.8.4"},
      {:poison, "~> 6.0"}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]
end
