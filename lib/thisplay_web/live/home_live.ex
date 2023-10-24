defmodule ThisplayWeb.HomeLive do
  use ThisplayWeb, :live_view

  alias Vix.Vips
  alias Thisplay.Toys

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:uploaded_files, [])
     |> allow_upload(:avatar, accept: ~w(.jpg .jpeg), max_entries: 1)}
  end

  @impl Phoenix.LiveView
  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :avatar, ref)}
  end

  @impl Phoenix.LiveView
  def handle_event("save", _params, socket) do
    result =
      consume_uploaded_entries(socket, :avatar, fn %{path: path}, _entry ->
        dest =
          Path.join([
            :code.priv_dir(:thisplay),
            "static",
            "uploads",
            Path.basename(path)
          ])

        public_url =
          Path.join([
            "uploads",
            Path.basename(path)
          ])

        File.cp!(path, dest)
        {:ok, {dest, public_url}}
      end)
      |> get_file()

    if result do
      {uploaded_file, public_url} = result

      %{"responses" => [%{"localizedObjectAnnotations" => objetos}]} =
        GoogleVisionAPI.detect_objects(uploaded_file)

      {:ok, img} = Vips.Image.new_from_file(uploaded_file)

      {:ok, %{id: document_id}} =
        Toys.create_document(%{filename: uploaded_file})

      objetos
      |> Enum.with_index()
      |> Enum.map(fn {%{
                        "boundingPoly" => %{
                          "normalizedVertices" => vertices
                        },
                        "name" => name
                      }, idx} ->
        result =
          vertices
          |> Enum.reduce({1, 0, 1, 0}, fn
            %{"x" => x, "y" => y}, {t_min_x, t_max_x, t_min_y, t_max_y} ->
              n_min_x = if x < t_min_x, do: x, else: t_min_x
              n_max_x = if x > t_max_x, do: x, else: t_max_x
              n_min_y = if y < t_min_y, do: y, else: t_min_y
              n_max_y = if y > t_max_y, do: y, else: t_max_y

              {n_min_x, n_max_x, n_min_y, n_max_y}

            _, _ ->
              nil
          end)

        if result do
          {min_x, max_x, min_y, max_y} = result
          {:ok, cropped_image} = Image.crop(img, min_x, min_y, max_x - min_x, max_y - min_y)

          cropped_filename = "#{uploaded_file}#{idx}.jpg"
          public_url = "#{public_url}#{idx}.jpg"
          Vips.Image.write_to_file(cropped_image, cropped_filename)
          Toys.create_toy(%{name: name, filename: public_url, document_id: document_id})
        end
      end)

      {:noreply, redirect(socket, to: ~p"/upload/#{document_id}")}
    else
      {:noreply, socket}
    end
  end

  defp get_file([file | _]), do: file
  defp get_file(_), do: nil

  defp error_to_string(:too_large), do: "Too large"
  defp error_to_string(:too_many_files), do: "You have selected too many files"
  defp error_to_string(:not_accepted), do: "You have selected an unacceptable file type"
end
