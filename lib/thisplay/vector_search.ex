defmodule Thisplay.VectorSearch do
  import Ecto.Query
  import Pgvector.Ecto.Query
  alias Thisplay.Repo
  alias Thisplay.Toys.ToyPicture

  def search_toy_pictures(id, embedding, user_id) do
    ToyPicture
    |> where(
      [t],
      t.user_id == ^user_id and
        t.id != ^id and
        not is_nil(t.toy_id) and
        l2_distance(t.embedding, ^embedding) < 1
    )
    |> order_by([t], l2_distance(t.embedding, ^embedding))
    |> limit(5)
    |> select_merge([t], %{distance: l2_distance(t.embedding, ^embedding)})
    |> Repo.all()
  end
end
