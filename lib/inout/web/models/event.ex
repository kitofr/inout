defmodule Inout.Web.Event do
  use Inout.Web, :model
  use Ecto.Schema
  import Ecto.Changeset

  @derive {
    Jason.Encoder,
    only: [:id, :status, :device, :location, :inserted_at, :updated_at, :posix]
  }
  schema "events" do
    field :status, :string
    field :device, :string
    field :location, :string

    belongs_to :user, User
    belongs_to :contract, Contract
    timestamps()
  end

  @updateable_fields ~w(status device location user_id contract_id inserted_at)a
  @required_fields ~w(status device location user_id contract_id)a

  @doc false
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @updateable_fields)
    |> validate_required(@required_fields)
  end
end
