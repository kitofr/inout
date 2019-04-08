defmodule Inout.Web.Event do
  use Inout.Web, :model
  use Ecto.Schema

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

  @required_fields ~w(status device location user_id contract_id)a
  @optional_fields ~w(inserted_at)a

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
