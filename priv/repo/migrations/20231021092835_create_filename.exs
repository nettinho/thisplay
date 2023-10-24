defmodule Thisplay.Repo.Migrations.CreateFilename do
  use Ecto.Migration

  def change do
    create table(:documents) do
      add :filename, :string
      add :live_session_id, :string

      timestamps(type: :utc_datetime)
    end
  end
end
