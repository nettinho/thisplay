defmodule Thisplay.Repo.Migrations.CreateVectorsTable do
  use Ecto.Migration

  def change do
    create table(:toy_pictures) do
      add :document_id, references(:documents, on_delete: :delete_all), null: false
      add :user_id, :integer
      add :filename, :string
      add :name, :string
      add :status, :string
      add :source, :integer
      add :embedding, :vector, size: 1408
      add :toy_id, :integer
      add :similars, {:array, :map}

      timestamps(type: :utc_datetime)
    end
  end
end
