defmodule ThisplayWeb.HomeLive do
  use ThisplayWeb, :live_view

  alias Thisplay.Toys

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:uploaded_files, [])
     |> assign(:uploading, false)
     |> allow_upload(:avatar,
       accept: ~w(.jpg .jpeg),
       max_entries: 1,
       auto_upload: true,
       progress: &handle_progress/3
     )}
  end

  defp handle_progress(:avatar, entry, socket) do
    if entry.done? do
      Task.async(fn -> handle_upload(socket, entry, self()) end)
      {:noreply, assign(socket, :uploading, true)}
    else
      {:noreply, socket}
    end
  end

  def handle_upload(socket, entry, pid) do
    document_id =
      consume_uploaded_entry(socket, entry, fn %{path: path} ->
        # epoch = System.system_time(:second)
        # image_path = "#{epoch}-#{Path.basename(path)}"

        # filename =
        #   Path.join([
        #     :code.priv_dir(:thisplay),
        #     "static",
        #     "uploads",
        #     image_path
        #   ])

        # filename = "/tmp/#{image_path}"
        # File.cp!(path, filename)

        filename = VertexAI.google_storage_post(path)

        %{current_user: %{id: user_id}} = socket.assigns

        {:ok, %{id: document_id} = doc} =
          Toys.create_document(%{filename: filename, user_id: user_id})

        Thisplay.Processor.process(doc)
        {:ok, document_id}
      end)

    send(pid, {:uploaded, document_id})
  end

  @impl true
  def handle_info({_, {:uploaded, document_id}}, socket) do
    {:noreply, redirect(socket, to: ~p"/upload/#{document_id}")}
  end

  @impl true
  def handle_event("validate", _params, socket), do: {:noreply, socket}
  def handle_event("save", _params, socket), do: {:noreply, socket}
end
