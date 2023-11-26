defmodule Thisplay.Toys.Document do
  use Ecto.Schema
  import Ecto.Changeset

  alias Thisplay.Toys.ToyPicture

  schema "documents" do
    field :filename, :string
    field :status, :string, default: "init"
    field :user_id, :integer

    has_many :toy_pictures, ToyPicture

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(document, attrs) do
    document
    |> cast(attrs, [:filename, :status, :user_id])
    |> validate_required([:filename])
  end
end
