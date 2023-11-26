defmodule Thisplay.Toys.Toy do
  use Ecto.Schema
  import Ecto.Changeset

  alias Thisplay.Toys.ToyPicture

  schema "toys" do
    field :name, :string
    field :frequency, :integer, default: 1
    field :user_id, :integer
    field :filename, :string, virtual: true
    field :count, :integer, virtual: true

    has_many :toy_pictures, ToyPicture

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(toy, attrs) do
    toy
    |> cast(attrs, [:name, :user_id, :frequency])
    |> validate_required([:name, :user_id])
  end
end
