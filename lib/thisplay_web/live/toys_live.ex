defmodule ThisplayWeb.ToysLive do
  alias Thisplay.Processor
  use ThisplayWeb, :live_view

  alias Thisplay.Toys

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(Thisplay.PubSub, "documents")
    end

    {:ok, socket}
  end

  def public_src(filename),
    do: VertexAI.google_storage_signed_url(filename)

  @impl true
  def handle_params(%{"id" => document_id}, _, socket) do
    document = Toys.get_document!(document_id)

    {:noreply,
     socket
     |> assign(:document, document)}
  end

  @impl true
  def handle_event("process", _, socket) do
    Processor.process(socket.assigns.document)
    {:noreply, socket}
  end

  @impl true
  def handle_event("process_toy", %{"toy" => toy_picture_id}, socket) do
    toy_picture_id
    |> Toys.get_toy_picture!()
    |> Processor.process()

    {:noreply, socket}
  end

  @impl true
  def handle_event("reset_toy", %{"toy" => toy_picture_id}, socket) do
    toy_picture_id
    |> Toys.get_toy_picture!()
    # |> Toys.update_toy_picture(%{status: "embedding_done"})
    |> Toys.update_toy_picture(%{status: "init"})

    {:noreply, socket}
  end

  @impl true
  def handle_event("reset", _, socket) do
    socket.assigns.document
    |> Toys.update_document(%{status: "init"})

    {:noreply, socket}
  end

  def handle_event("delete", %{"id" => id}, socket) do
    id
    |> Toys.get_toy_picture!()
    |> Toys.delete_toy_picture()

    {:noreply, socket}
  end

  @impl true
  def handle_event("changed", %{"toy" => toy_id, "value" => name}, socket) do
    toy_id
    |> Toys.get_toy_picture!()
    |> Toys.update_toy_picture(%{name: name, source: nil})

    {:noreply, socket}
  end

  def handle_event("next", _, socket) do
    %{toy_pictures: toys} = socket.assigns.document

    Enum.each(toys, &Toys.put_toy_from_picture/1)

    {:noreply, redirect(socket, to: ~p"/list")}
  end

  def handle_event(
        "select_suggestion",
        %{"toy" => id, "suggestion" => suggestion, "name" => name},
        socket
      ) do
    id
    |> Toys.get_toy_picture!()
    |> Toys.update_toy_picture(%{source: suggestion, name: name})

    {:noreply, socket}
  end

  def handle_event("clear_suggestion", %{"toy" => id}, socket) do
    id
    |> Toys.get_toy_picture!()
    |> Toys.update_toy_picture(%{source: nil})

    {:noreply, socket}
  end

  @impl true
  def handle_info({:update, %{id: id} = document}, %{assigns: %{document: %{id: id}}} = socket) do
    {:noreply, assign(socket, :document, document)}
  end

  def handle_info(_, socket), do: {:noreply, socket}
end
