defmodule Inout.Web.EventController do
  use Inout.Web, :controller
  require Logger
  require Jason

  alias Inout.Web.Event
  alias Inout.Web.User
  alias Inout.Web.Contract
  alias Inout.Web.Session


  plug :scrub_params, "event" when action in [:create, :update]

  defp get_event(conn, id) do
    user_id = Session.current_user(conn).id
    query = from e in Event,
              join: c in Contract, on: e.contract_id == c.id,
              where: e.user_id == ^user_id,
              where: e.id == ^id,
              preload: [contract: c]

    Repo.one(query)
  end

  def index(conn, _params) do
    user_id = Session.current_user(conn).id
    query = from e in Event,
              join: c in Contract, on: e.contract_id == c.id,
              join: u in User, on: e.user_id == u.id,
              where: e.user_id == ^user_id,
              order_by: [desc: e.inserted_at],
              preload: [contract: c, user: u]

    events = Repo.all(query)
              |> Enum.map(fn e -> Map.put_new(e, :posix, to_unix(e.inserted_at)) end)

    render(conn, "index.html", events: events)
  end

  defp to_unix(datetime) do
    datetime |> NaiveDateTime.to_erl |> :calendar.datetime_to_gregorian_seconds |> Kernel.-(62167219200)
  end

  def as_json(conn, _params) do
    user_id = Session.current_user(conn).id
    query = from e in Event,
              join: c in Contract, on: e.contract_id == c.id,
              join: u in User, on: e.user_id == u.id,
              where: e.user_id == ^user_id,
              order_by: [desc: e.inserted_at],
              preload: [contract: c, user: u]

    events = Repo.all(query)
              |> Enum.map(fn e -> Map.put_new(e, :posix, to_unix(e.inserted_at)) end)

    json(conn, %{ events: events })
  end

  def new(conn, _params) do
    changeset = Event.changeset(%Event{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"event" => event_params}) do
    user_id = Session.current_user(conn).id
    last_contract = Contract |> Ecto.Query.last |> Inout.Repo.one

    changeset = Event.changeset(
        %Event{},
        Map.merge(event_params, %{ "user_id" => "#{user_id}", "contract_id" => "#{last_contract.id}" } ))

    case Repo.insert(changeset) do
      {:ok, event} ->
        json(conn, %{ event:  add_posix(event)})
      {:error, changeset} ->
        json conn, %{ error: changeset }
    end
  end

  def show(conn, %{"id" => id}) do
    event = get_event(conn, id)

    render(conn, "show.html", event: event)
  end

  def edit(conn, %{"id" => id}) do
    event = get_event(conn, id)
    contracts = Repo.all(from(c in Contract, select: { c.client, c.id }))

    changeset = Event.changeset(event, %{})
    render(conn, "edit.html", event: event, contracts: contracts, changeset: changeset)
  end

  def add_posix(event) do
    Map.put_new(event, :posix, to_unix(event.inserted_at))
  end

  def update(conn, %{"id" => id, "event" => event_params}) do
    event = get_event(conn, id)
    changeset = Event.changeset(event, event_params)

    case Repo.update(changeset) do
      {:ok, event} ->
        json(conn, add_posix(event))
      {:error, changeset} ->
        render(conn, "edit.html", event: event, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    event = get_event(conn, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(event)

    conn
    |> put_flash(:info, "Event deleted successfully.")
    |> json(nil)
  end
end
