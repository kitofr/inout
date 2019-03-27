# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :inout, Inout.Web.Endpoint,
  url: [host: "localhost"],
  root: Path.dirname(__DIR__),
  secret_key_base: "RYhUMSv03xrQCkUbnPwMxh6gG1ld7ZYbass1a1+FuQq6fS3+NeUvpAcfNFh2EZLl",
  render_errors: [view: Inout.Web.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Inout.PubSub,
           adapter: Phoenix.PubSub.PG2]

  config :inout,
    ecto_repos: [Inout.Repo]

  config :phoenix, :json_library, Poison

# config :inout, Inout.Repo,
#   adapter: Ecto.Adapters.Postgres,
#   username: System.get_env("POSTGRES_USER") || "postgres",
#   password: System.get_env("POSTGRES_PASSWORD") || "postgres",
#   database: System.get_env("POSTGRES_DB") || "inout_dev",
#   hostname: System.get_env("POSTGRES_HOST") || "localhost",
#   pool: Ecto.Adapters.SQL.Sandbox

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"

# Configure phoenix generators
config :phoenix, :generators,
  migration: true,
  binary_id: false
