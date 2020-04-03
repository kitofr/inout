defmodule Inout.Web.User do
  use Inout.Web, :model
  use Ecto.Schema
  alias Inout.Web.Event
  alias Inout.Web.Contract

  @derive {
    Jason.Encoder,
    only: [:email, :password]
  }
  schema "users" do
    field :email, :string
    field :crypted_password, :string
    field :password, :string, virtual: true
    has_many :events, Event
    has_many :contracts, Contract
    timestamps()
  end

  @required_fields ~w(email password)
  @optional_fields ~w()

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> unique_constraint(:email)
    |> validate_format(:email, ~r/@/)
    |> validate_length(:password, min: 8)
  end
end
