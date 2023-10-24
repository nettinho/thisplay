defmodule Thisplay.Toys.Toy do
  use Ecto.Schema
  import Ecto.Changeset

  alias Thisplay.Toys.Document

  schema "toys" do
    field :name, :string
    field :filename, :string
    field :frequency, :integer, default: 1

    belongs_to :document, Document

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(toy, attrs) do
    toy
    |> cast(attrs, [:name, :filename, :document_id, :frequency])
    |> validate_required([:name, :filename])
  end
end
