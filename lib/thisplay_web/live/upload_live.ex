defmodule ThisplayWeb.UploadLive do
  use ThisplayWeb, :live_view

  alias Thisplay.Toys

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_params(%{"id" => document_id}, _, socket) do
    %{toys: toys} = Toys.get_document!(document_id)
    {:noreply, assign(socket, :toys, toys)}
  end

  def handle_event("delete", %{"id" => id}, socket) do
    IO.inspect(id, label: "DELETE")
    {:noreply, socket}
  end
end
