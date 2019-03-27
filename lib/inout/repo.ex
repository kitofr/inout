defmodule Inout.Repo do
  use Ecto.Repo,
    otp_app: :inout,
    adapter: Ecto.Adapters.Postgres
end
