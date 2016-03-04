defmodule Inout.Event do
  use Inout.Web, :model

  @derive {Poison.Encoder, only: [:status, :device, :location, :inserted_at, :updated_at]}
  schema "events" do
    field :status, :string
    field :device, :string
    field :location, :string

    timestamps
  end

  @required_fields ~w(status device location)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end
end
