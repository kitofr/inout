
defmodule Inout.Repo.Migrations.CreateContracts do
  use Ecto.Migration

  def change do
    create table(:contracts) do
      add :client     , :string
      add :reference  , :string
      add :address    , :string
      add :postalcode , :string
      add :country    , :string
      add :description, :string
      add :email      , :string
      add :hourly_rate, :int

      add :user_id, references(:users)

      timestamps()
    end
    alter table(:events) do
      add :contract_id, references(:contracts) 
    end
  end
end
