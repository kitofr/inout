defmodule Inout.EventController do
  use Inout.Web, :controller

  alias Inout.Event

  plug :scrub_params, "event" when action in [:create, :update]

  def index(conn, _params) do
    user_id = Inout.Session.current_user(conn).id
    events = Repo.all(from e in Inout.Event, where: e.user_id == ^user_id, order_by: [desc: e.inserted_at])
    render(conn, "index.html", events: events)
  end

  def as_json(conn, _params) do
    user_id = Inout.Session.current_user(conn).id
    events = Repo.all(from e in Inout.Event,
     where: e.user_id == ^user_id
     #select: %{
     #  id: e.id,
     #  inserted_at: e.inserted_at,
     #  updated_at: e.updated_at,
     #  device: e.device,
     #  location: e.location,
     #  status: e.status
     #}
    )
    json(conn, %{ events: events })
  end

  def new(conn, _params) do
    changeset = Event.changeset(%Event{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"event" => event_params}) do
    user_id = Inout.Session.current_user(conn).id
    changeset = Event.changeset(%Event{}, Map.merge(event_params, %{ "user_id" => "#{user_id}" } ))

    case Repo.insert(changeset) do
      {:ok, _event} ->
        json conn, %{ event: changeset }
      {:error, changeset} ->
        json conn, %{ error: changeset }
    end
  end

  def show(conn, %{"id" => id}) do
    event = Repo.get!(Event, id)
    render(conn, "show.html", event: event)
  end

  def edit(conn, %{"id" => id}) do
    event = Repo.get!(Event, id)
    changeset = Event.changeset(event)
    render(conn, "edit.html", event: event, changeset: changeset)
  end

  def update(conn, %{"id" => id, "event" => event_params}) do
    event = Repo.get!(Event, id)
    changeset = Event.changeset(event, event_params)

    case Repo.update(changeset) do
      {:ok, event} ->
        conn
        |> put_flash(:info, "Event updated successfully.")
        |> redirect(to: event_path(conn, :show, event))
      {:error, changeset} ->
        render(conn, "edit.html", event: event, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    event = Repo.get!(Event, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(event)

    conn
    |> put_flash(:info, "Event deleted successfully.")
    |> json nil
  end
end
