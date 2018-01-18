defmodule Inout.User do
  use Inout.Web, :model
  use Ecto.Schema
  alias Inout.Event
  alias Inout.Contract

  schema "users" do
    field :email, :string
    field :crypted_password, :string
    field :password, :string, virtual: true
    has_many :events, Event
    has_many :contracts, Contract
    timestamps()
  end

  @required_fields ~w(email password)a

  @doc false
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields)
    |> validate_required(@required_fields)
    |> unique_constraint(:email)
    |> validate_format(:email, ~r/@/)
    |> validate_length(:password, min: 8)
  end
end
