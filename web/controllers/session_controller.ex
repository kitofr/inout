defmodule Inout.SessionController do
  use Inout.Web, :controller

  def new(conn, _params) do
    render conn, "new.html"
  end

  def create(conn, %{"email" => email, "password" => password}) do
    case Inout.Session.login(%{"email" => email, "password" => password}, Inout.Repo) do
      {:ok, user} ->
        conn
        |> put_session(:current_user, user.id)
        |> put_flash(:info, "Logged in")
        |> redirect(to: "/")
      :error ->
        conn
        |> put_flash(:info, "Wrong email or password")
        |> render("new.html")
    end
  end

  def delete(conn, _) do
    conn
    |> delete_session(:current_user)
    |> put_flash(:info, "Logged out")
    |> redirect( to: "/")
  end
end
