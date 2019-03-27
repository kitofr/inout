defmodule Inout.Web.RegistrationController do
  use Inout.Web, :controller
  alias Inout.Web.User
  alias Inout.Web.Registration

   def new(conn, _params) do
     changeset = User.changeset(%User{})
     render conn, changeset: changeset
   end

   def create(conn, %{"user" => user_params}) do
     changeset = User.changeset(%User{}, user_params)

     case Registration.create(changeset, Inout.Repo) do
       { :ok, changeset } -> #user sign in
       conn
       |> put_session(:current_user, changeset.id)
       |> put_flash(:info, "Your account was created")
       |> redirect(to: "/")

       { :error, changeset } -> #show error
       conn
       |> put_flash(:info, "Unable to create account")
       |> render("new.html", changeset: changeset)
     end
   end
end
