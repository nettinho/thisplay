defmodule Thisplay.Processor do
  alias Thisplay.Toys.ToyPicture
  alias Thisplay.Toys
  alias Thisplay.Toys.Document
  alias Thisplay.VectorSearch

  alias Vix.Vips

  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def init(_) do
    {:ok, nil}
  end

  def process(item) do
    GenServer.cast(__MODULE__, {:process, item})
  end

  @impl true
  def handle_cast({:process, %Document{} = doc}, _) do
    Task.async(fn -> process_document(doc) end)
    {:noreply, nil}
  end

  def handle_cast({:process, %ToyPicture{} = toy_picture}, _) do
    Task.async(fn -> process_toy_picture(toy_picture) end)
    {:noreply, nil}
  end

  @impl true
  def handle_info(_message, socket) do
    {:noreply, socket}
  end

  defp process_document(%{status: "init", filename: filename, user_id: user_id} = doc) do
    Toys.update_document(doc, %{status: "processing"})

    status =
      with {:google_vision, %{"responses" => [%{"localizedObjectAnnotations" => objects}]}} <-
             {:google_vision, GoogleVisionAPI.detect_objects(filename)},
           {:download_image, image_path} <-
             {:download_image, VertexAI.google_storage_get(filename)},
           {:load_image, {:ok, img}} <- {:load_image, Vips.Image.new_from_file(image_path)} do
        objects
        |> Enum.with_index()
        |> Enum.each(fn {%{"boundingPoly" => %{"normalizedVertices" => vertices}, "name" => name},
                         idx} ->
          cropped_filename = "/tmp/#{filename}#{idx}.jpg"

          vertices
          |> Enum.reduce({1, 0, 1, 0}, &reduce_vertices/2)
          |> crop_image(img)
          |> write_cropped_image(cropped_filename)
          |> upload_to_google(cropped_filename)
          |> create_toy_picture(%{
            name: name,
            document_id: doc.id,
            user_id: user_id
          })

          # |> request_embedding(cropped_filename)
          # |> create_toy(%{name: name, filename: cropped_filename, document_id: doc.id})
        end)

        "success"
      else
        {:google_vision, _} -> "error_google_vision"
        {:download_image, _} -> "error_downloading_image"
        {:load_image, _} -> "error_loading_image"
      end

    Toys.update_document(doc, %{status: status})
  end

  defp process_toy_picture(%{status: "init", filename: filename} = toy_picture) do
    Toys.update_toy_picture(toy_picture, %{status: "fetching_embedding"})

    {:ok, toy_picture} =
      with {:embedding, [_ | _] = embedding} <-
             {:embedding, VertexAI.image_embedding(filename)} do
        # |> request_embedding(cropped_filename)
        # |> create_toy(%{name: name, filename: cropped_filename, document_id: doc.id})

        Toys.update_toy_picture(toy_picture, %{embedding: embedding, status: "embedding_done"})
      else
        {:embedding, error} ->
          IO.inspect(error)
          Toys.update_toy_picture(toy_picture, %{status: "embedding_error"})
      end

    process_toy_picture(toy_picture)
  end

  defp process_toy_picture(
         %{status: "embedding_done", embedding: embedding, user_id: user_id, id: id} = toy_picture
       ) do
    Toys.update_toy_picture(toy_picture, %{status: "searching_similars"})

    similars =
      VectorSearch.search_toy_pictures(id, embedding, user_id)
      |> Enum.group_by(&Map.get(&1, :toy_id))
      |> Enum.map(fn {toy_id,
                      [%{filename: filename, distance: distance, name: name} | _] = pictures} ->
        %{
          toy_id: toy_id,
          filename: filename,
          count: Enum.count(pictures),
          distance: distance,
          name: name
        }
      end)
      |> Enum.sort(fn %{count: count_a, distance: distance_a},
                      %{count: count_b, distance: distance_b} ->
        count_a > count_b or (count_a == count_b and distance_a < distance_b)
      end)
      |> Enum.take(3)

    status = "done"

    initial_source = get_source(similars)
    initial_name = get_name(similars)

    {:ok, toy_picture} =
      Toys.update_toy_picture(toy_picture, %{
        status: status,
        similars: similars,
        source: initial_source,
        name: initial_name
      })

    process_toy_picture(toy_picture)
  end

  defp process_toy_picture(%{status: status})
       when status in ["done", "embedding_error"] do
    nil
  end

  defp process_toy_picture(toy_picture) do
    IO.inspect(toy_picture, label: " invalid toy_picture process")
    nil
  end

  defp get_source([%{toy_id: toy_id} | _]), do: toy_id
  defp get_source(_), do: nil

  defp get_name([%{name: name} | _]), do: name
  defp get_name(_), do: nil

  defp reduce_vertices(%{"x" => x, "y" => y}, {t_min_x, t_max_x, t_min_y, t_max_y}) do
    n_min_x = if x < t_min_x, do: x, else: t_min_x
    n_max_x = if x > t_max_x, do: x, else: t_max_x
    n_min_y = if y < t_min_y, do: y, else: t_min_y
    n_max_y = if y > t_max_y, do: y, else: t_max_y

    {n_min_x, n_max_x, n_min_y, n_max_y}
  end

  defp reduce_vertices(_, acc), do: acc

  defp crop_image({min_x, max_x, min_y, max_y}, img),
    do: Image.crop(img, min_x, min_y, max_x - min_x, max_y - min_y)

  defp crop_image(_, _), do: nil

  defp write_cropped_image({:ok, cropped_image}, cropped_filename),
    do: Vips.Image.write_to_file(cropped_image, cropped_filename)

  defp write_cropped_image(_, _), do: nil

  # defp create_toy(nil, _), do: nil

  # defp create_toy(_embedding, params) do
  #   Toys.create_toy(params)
  # end

  defp upload_to_google(:ok, path) do
    filename = VertexAI.google_storage_post(path)
    {:ok, filename}
  end

  defp upload_to_google(_, _), do: nil

  defp create_toy_picture({:ok, filename}, params) do
    params = Map.put(params, :filename, filename)
    Toys.create_toy_picture(params)
  end

  defp create_toy_picture(_, _), do: nil
end
