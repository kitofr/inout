Postgrex.Types.define(
  Inout.PostgrexTypes,
  [] ++ Ecto.Adapters.Postgres.extensions(),
  json: Jason
)
