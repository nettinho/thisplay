defmodule Thisplay.Repo.Migrations.CreateToys do
  use Ecto.Migration

  def change do
    create table(:toys) do
      add :document_id, references(:documents, on_delete: :delete_all), null: false
      add :name, :string
      add :filename, :string
      add :frequency, :integer
      timestamps(type: :utc_datetime)
    end
  end
end
