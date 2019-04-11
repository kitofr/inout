defmodule Inout.Web.Contract do
  use Inout.Web, :model
  use Ecto.Schema

  @derive {
    Jason.Encoder,
    only: [:id, :client, :reference, :address, :postalcode, :country, :description, :email, :hourly_rate]
  }
  schema "contracts" do
    field :client, :string
    field :reference, :string
    field :address, :string
    field :postalcode, :string
    field :country, :string
    field :description, :string
    field :email, :string
    field :hourly_rate, :integer

    belongs_to :user, User
    timestamps()
  end

  @required_fields ~w(client hourly_rate user_id)
  @optional_fields ~w(reference address postalcode country description email inserted_at)

  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end
end
