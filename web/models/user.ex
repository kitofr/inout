defmodule Inout.User do
  use Inout.Web, :model
  use Ecto.Schema

  schema "users" do
    field :email, :string
    field :crypted_password, :string
    field :password, :string, virtual: true
    has_many :events, Event
    timestamps()
  end

  @required_fields ~w(email password)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> unique_constraint(:email)
    |> validate_format(:email, ~r/@/)
    |> validate_length(:password, min: 8)
  end
end
