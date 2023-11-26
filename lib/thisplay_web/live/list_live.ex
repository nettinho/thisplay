defmodule ThisplayWeb.ListLive do
  alias Thisplay.Toys
  use ThisplayWeb, :live_view

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    %{id: user_id} = socket.assigns.current_user

    toys =
      user_id
      |> Toys.list_toys_by_user()
      |> Enum.map(&%{&1 | filename: first_filename(&1), count: count_toys(&1)})

    top3 =
      toys
      |> Enum.sort_by(& &1.count, :desc)
      |> Enum.take(3)

    top_new =
      toys
      |> Enum.sort_by(& &1.inserted_at, :desc)
      |> Enum.take(3)

    rest = (toys -- top3) |> Kernel.--(top_new)

    {:ok,
     socket
     |> assign(:toys, toys)
     |> assign(:top3, top3)
     |> assign(:top_new, top_new)
     |> assign(:rest, rest)}
  end

  def first_filename(%{toy_pictures: [%{filename: filename} | _]}), do: public_src(filename)
  def first_filename(_), do: ""
  def count_toys(%{toy_pictures: [_ | _] = toys}), do: Enum.count(toys)
  def count_toys(_), do: 0

  def public_src(filename),
    do: VertexAI.google_storage_signed_url(filename)
end
