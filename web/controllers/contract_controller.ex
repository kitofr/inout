defmodule Inout.ContractController do
  use Inout.Web, :controller

  def index(conn, _params) do
    user_id = Inout.Session.current_user(conn).id
    contracts = Repo.all(from c in Inout.Contract, where: c.user_id == ^user_id, order_by: [desc: c.inserted_at])
    json(conn, %{ contracts: contracts })
  end
end
