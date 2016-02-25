ExUnit.start

Mix.Task.run "ecto.create", ~w(-r Inout.Repo --quiet)
Mix.Task.run "ecto.migrate", ~w(-r Inout.Repo --quiet)
Ecto.Adapters.SQL.begin_test_transaction(Inout.Repo)

