defmodule Inout.Mixfile do
  use Mix.Project

  def project do
    [app: :inout,
     version: "0.0.2",
     elixir: "~> 1.10",
     elixirc_paths: elixirc_paths(Mix.env),
     compilers: [:phoenix, :gettext] ++ Mix.compilers,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     aliases: aliases(),
     deps: deps()]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [mod: {Inout, []},
     applications: [:phoenix, :phoenix_pubsub, :phoenix_html, :cowboy, :logger, :gettext,
                    :phoenix_ecto, :ecto_sql, :postgrex, :httpotion]]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [{:phoenix, "~> 1.4.0"},
     {:phoenix_pubsub, "~> 1.0"},
     {:postgrex, ">= 0.0.0"},
     {:ecto_sql, "~> 3.0"},
     {:phoenix_ecto, "~> 4.0"},
     {:phoenix_html, "~> 2.4"},
     {:phoenix_live_reload, "~> 1.0", only: :dev},
     {:comeonin, "~> 1.0"},
     {:jason, "~> 1.0"},
     {:gettext, "~> 0.9"},
     {:good_times, "~> 1.1"},
     {:httpotion, "~> 3.0.0"},
     {:plug, "~> 1.7"},
     {:corsica, "~> 0.4"},
     {:plug_cowboy, "~> 2.0"}]
  end

  # Aliases are shortcut or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    ["ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
     "ecto.reset": ["ecto.drop", "ecto.setup"]]
  end
end
