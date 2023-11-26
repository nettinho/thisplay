defmodule Thisplay.Repo.Migrations.CreateToys do
  use Ecto.Migration

  def change do
    create table(:toys) do
      add :name, :string
      add :frequency, :integer
      add :user_id, :integer

      timestamps(type: :utc_datetime)
    end
  end
end
