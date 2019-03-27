defmodule Inout.Web.ContractController do
  use Inout.Web, :controller

  alias Inout.Web.Contract
  alias Inout.Web.Session

  plug :scrub_params, "contract" when action in [:create, :update]

  def index(conn, _params) do
    user_id = Session.current_user(conn).id
    contracts = Repo.all(from c in Contract, where: c.user_id == ^user_id, order_by: [desc: c.inserted_at])
    render(conn, "index.html", contracts: contracts )
  end

  def as_json(conn, _params) do
    user_id = Session.current_user(conn).id
    contracts = Repo.all(from c in Contract, where: c.user_id == ^user_id, order_by: [desc: c.inserted_at])
    json(conn, %{ contracts: contracts })
  end

  def new(conn, _params) do
    changeset = Contract.changeset(%Contract{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"contract" => contract_params}) do
    user_id = Session.current_user(conn).id
    changeset = Contract.changeset(
       %Contract{},
       Map.merge(contract_params, %{ "user_id" => "#{user_id}" } ))

    case Repo.insert(changeset) do
      {:ok, contract} ->
        json conn, %{ contract: contract }
      {:error, changeset} ->
        json conn, %{ error: changeset }
    end
  end

  def update(conn, %{"id" => id, "contract" => contract_params}) do
    #TODO Make sure you only update your own contracts
    contract = Repo.get!(Contract, id)
    changeset = Contract.changeset(contract, contract_params)

    case Repo.update(changeset) do
      {:ok, contract} ->
        conn
        |> put_flash(:info, "Contract updated successfully.")
        |> fn (conn) -> render(conn, "edit.html", contract: contract, changeset: changeset) end.()
      {:error, changeset} ->
        render(conn, "edit.html", contract: contract, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    contract = Repo.get!(Contract, id)
    render(conn, "show.html", contract: contract)
  end

  def edit(conn, %{"id" => id}) do
    contract = Repo.get!(Contract, id)
    changeset = Contract.changeset(contract)
    render(conn, "edit.html", contract: contract, changeset: changeset)
  end
end
