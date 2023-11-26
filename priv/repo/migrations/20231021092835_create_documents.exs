defmodule Thisplay.Repo.Migrations.CreateDocuments do
  use Ecto.Migration

  def change do
    create table(:documents) do
      add :filename, :string
      add :status, :string
      add :user_id, :integer

      timestamps(type: :utc_datetime)
    end
  end
end
