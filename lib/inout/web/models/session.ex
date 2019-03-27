defmodule Inout.Web.Session do
  alias Inout.Web.User

  def login(email, password, repo) do
    user = repo.get_by(User, email: String.downcase(email))
    case authenticate(user, password) do
      true -> { :ok, user }
      _    -> :error
    end
  end

  def current_user(conn) do
    id = Plug.Conn.get_session(conn, :current_user)
    if id, do: Inout.Repo.get(User, id)
  end

  def logged_in?(conn), do: !!current_user(conn)

  defp authenticate(user, password) do
    case user do
      nil -> false
      _   -> Comeonin.Bcrypt.checkpw(password, user.crypted_password)
    end
  end
end
