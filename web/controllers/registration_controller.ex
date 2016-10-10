defmodule Inout.RegistrationController do
  use Inout.Web, :controller
  alias Inout.User

   def new(conn, _params) do
     changeset = User.changeset(%User{})
     render conn, changeset: changeset
   end
end
