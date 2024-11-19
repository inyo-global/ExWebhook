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
      deps: deps()
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
      {:broadway, "~> 1.1.0"},
      {:broadway_kafka, "~> 0.4.4"},
      {:jason, "~> 1.4"},
      {:uuid, "~> 1.1"},
      {:ecto_sql, "~> 3.12"},
      {:postgrex, "~> 0.15"},
      {:typed_ecto_schema, "~> 0.4.1", runtime: false},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.34", only: :dev, runtime: false},
      {:httpoison, "~> 2.2.1"}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]
end
