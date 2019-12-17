# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Inout.Repo.insert!(%Inout.SomeModel{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Inout.Repo
alias Inout.Web.User
alias Inout.Web.Contract
alias Inout.Web.Event

Repo.insert! %User{
  email: "foo@protonmail.com",
  password: "nothing.serious",
  crypted_password: Comeonin.Bcrypt.hashpwsalt("nothing.serious")
}

Repo.insert! %Contract{
  client: "Acme AB",
  reference: "Donald Duck",
  address: "DuckTown 1",
  postalcode: "111 23",
  country: "Duckland",
  description: "Duckely things",
  email: "donald.duck@ducktown.com",
  hourly_rate: 1050,
  user_id: 1,
}

Enum.each(0..99, fn(x) ->
  inserted = NaiveDateTime.utc_now() |> NaiveDateTime.add(-60 * 60 * 24 * x) |> NaiveDateTime.truncate :second

  Repo.insert! %Event{
    status: "check-in",
    device: "web",
    location: "Stockholm",
    inserted_at: inserted,
    user_id: 1,
    contract_id: 1,
  }

  hours = Enum.random(0..9)
  Repo.insert! %Event{
    status: "check-out",
    device: "web",
    location: "Stockholm",
    inserted_at: inserted |> NaiveDateTime.add(60*60*hours),
    user_id: 1,
    contract_id: 1,
  }
end)
