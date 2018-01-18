defmodule Inout.Event do
  use Inout.Web, :model
  use Ecto.Schema
  alias Inout.User
  alias Inout.Contract

  @derive {
    Poison.Encoder,
    only: [:id, :status, :device, :location, :inserted_at, :updated_at]
  }

  schema "events" do
    field :status, :string
    field :device, :string
    field :location, :string

    belongs_to :user, User
    belongs_to :contract, Contract
    timestamps()
  end

  @required_fields ~w(status device location user_id contract_id)a

  @doc false
  def changeset(%Inout.Event{} = model, params \\ :empty) do
    model
    |> cast(params, @required_fields)
    |> validate_required(@required_fields)
  end
end
