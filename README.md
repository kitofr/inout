# Inout

[![Build Status](https://travis-ci.org/kitofr/inout.svg?branch=master)](https://travis-ci.org/kitofr/inout)

To start your Phoenix app:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.create && mix ecto.migrate`
  * Install Node.js dependencies with `npm install`
  * Start Phoenix endpoint with `mix phoenix.server`
  * Import database with `pg_restore --verbose --clean --no-acl --no-owner -h localhost -U postgres -d inout_dev latest.dump`
    ```sh
    ./restore.sh
    ```

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](http://www.phoenixframework.org/docs/deployment).

# Ecto queries
```
iex> alias Ecto.Query
iex> Inout.Event |> Ecto.Query.limit(2) |> Inout.Repo.all
```

