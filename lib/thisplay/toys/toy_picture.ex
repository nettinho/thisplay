defmodule Thisplay.Toys.ToyPicture do
  use Ecto.Schema
  import Ecto.Changeset

  alias Thisplay.Toys.Toy
  alias Thisplay.Toys.Document

  schema "toy_pictures" do
    field :user_id, :integer
    field :filename, :string
    field :name, :string
    field :status, :string, default: "init"
    field :embedding, Pgvector.Ecto.Vector

    field :distance, :float, virtual: true
    field :similars, {:array, :map}
    field :source, :integer

    belongs_to :document, Document
    belongs_to :toy, Toy

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(toy_picture, attrs) do
    toy_picture
    |> cast(attrs, [
      :user_id,
      :filename,
      :status,
      :name,
      :document_id,
      :embedding,
      :toy_id,
      :similars,
      :source
    ])
    |> validate_required([:user_id, :filename, :document_id])
  end
end
