defmodule Inout.Repo.Migrations.CreateEvent do
  use Ecto.Migration

  def change do
    create table(:events) do
      add :status, :string
      add :device, :string
      add :location, :string

      timestamps()
    end

  end
end
