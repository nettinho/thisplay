defmodule Thisplay.Toys.Document do
  use Ecto.Schema
  import Ecto.Changeset

  alias Thisplay.Toys.Toy

  schema "documents" do
    field :filename, :string
    field :live_session_id, :string

    has_many :toys, Toy

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(document, attrs) do
    document
    |> cast(attrs, [:filename])
    |> validate_required([:filename])
  end
end
