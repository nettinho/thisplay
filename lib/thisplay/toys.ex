defmodule Thisplay.Toys do
  @moduledoc """
  The Toys context.
  """

  import Ecto.Query, warn: false
  alias Thisplay.Repo

  alias Thisplay.Toys.Toy
  alias Thisplay.Toys.ToyPicture

  @doc """
  Returns the list of toys.

  ## Examples

      iex> list_toys()
      [%Toy{}, ...]

  """
  def list_toys do
    Repo.all(Toy)
  end

  def list_toys_by_user(user_id) do
    Toy
    |> where([t], t.user_id == ^user_id)
    |> Repo.all()
    |> Repo.preload(:toy_pictures)
  end

  @doc """
  Gets a single toy.

  Raises `Ecto.NoResultsError` if the Toy does not exist.

  ## Examples

      iex> get_toy!(123)
      %Toy{}

      iex> get_toy!(456)
      ** (Ecto.NoResultsError)

  """
  def get_toy!(id), do: Repo.get!(Toy, id)

  @doc """
  Creates a toy.

  ## Examples

      iex> create_toy(%{field: value})
      {:ok, %Toy{}}

      iex> create_toy(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_toy(attrs \\ %{}) do
    %Toy{}
    |> Toy.changeset(attrs)
    |> Repo.insert()
    |> broadcast_toy_created()
  end

  def put_toy_from_picture(%ToyPicture{source: nil} = picture) do
    %Toy{}
    |> Toy.changeset(%{name: picture.name, user_id: picture.user_id})
    |> Repo.insert()
    |> maybe_update_toy_picture(picture)
  end

  def put_toy_from_picture(%ToyPicture{source: source} = picture) do
    update_toy_picture(picture, %{toy_id: source})
  end

  defp maybe_update_toy_picture({:ok, %{id: id}} = result, picture) do
    update_toy_picture(picture, %{toy_id: id})
    result
  end

  defp maybe_update_toy_picture(error, _), do: error

  defp broadcast_toy_created({:ok, %{document_id: doc_id}} = result) do
    document =
      doc_id
      |> get_document!()
      |> Repo.preload(:toys)

    broadcast_document({:ok, document}, :update)
    result
  end

  defp broadcast_toy_created(error), do: error

  @doc """
  Updates a toy.

  ## Examples

      iex> update_toy(toy, %{field: new_value})
      {:ok, %Toy{}}

      iex> update_toy(toy, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_toy(%Toy{} = toy, attrs) do
    toy
    |> Toy.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a toy.

  ## Examples

      iex> delete_toy(toy)
      {:ok, %Toy{}}

      iex> delete_toy(toy)
      {:error, %Ecto.Changeset{}}

  """
  def delete_toy(%Toy{} = toy) do
    Repo.delete(toy)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking toy changes.

  ## Examples

      iex> change_toy(toy)
      %Ecto.Changeset{data: %Toy{}}

  """
  def change_toy(%Toy{} = toy, attrs \\ %{}) do
    Toy.changeset(toy, attrs)
  end

  alias Thisplay.Toys.Document

  @doc """
  Returns the list of documents.

  ## Examples

      iex> list_documents()
      [%Document{}, ...]

  """
  def list_documents do
    Repo.all(Document)
  end

  @doc """
  Gets a single document.

  Raises `Ecto.NoResultsError` if the Document does not exist.

  ## Examples

      iex> get_document!(123)
      %Document{}

      iex> get_document!(456)
      ** (Ecto.NoResultsError)

  """
  def get_document!(id), do: Repo.get!(Document, id) |> preload_toy_pictures

  @doc """
  Creates a document.

  ## Examples

      iex> create_document(%{field: value})
      {:ok, %Document{}}

      iex> create_document(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_document(attrs \\ %{}) do
    %Document{}
    |> Document.changeset(attrs)
    |> Repo.insert()
    |> broadcast_document(:create)
  end

  @doc """
  Updates a document.

  ## Examples

      iex> update_document(document, %{field: new_value})
      {:ok, %Document{}}

      iex> update_document(document, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_document(%Document{} = document, attrs) do
    document
    |> Document.changeset(attrs)
    |> Repo.update()
    |> broadcast_document(:update)
  end

  @doc """
  Deletes a document.

  ## Examples

      iex> delete_document(document)
      {:ok, %Document{}}

      iex> delete_document(document)
      {:error, %Ecto.Changeset{}}

  """
  def delete_document(%Document{} = document) do
    Repo.delete(document)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking document changes.

  ## Examples

      iex> change_document(document)
      %Ecto.Changeset{data: %Document{}}

  """
  def change_document(%Document{} = document, attrs \\ %{}) do
    Document.changeset(document, attrs)
  end

  defp broadcast_document({:ok, %{id: id}}, action) do
    document =
      id
      |> get_document!()
      |> preload_toy_pictures()

    Phoenix.PubSub.broadcast!(Thisplay.PubSub, "documents", {action, document})
    {:ok, document}
  end

  defp broadcast_document(error, _), do: error

  def create_toy_picture(attrs \\ %{}) do
    %ToyPicture{}
    |> ToyPicture.changeset(attrs)
    |> Repo.insert()
    |> broadcast_toy_picture_created()
  end

  def update_toy_picture(toy_picture, attrs \\ %{}) do
    toy_picture
    |> ToyPicture.changeset(attrs)
    |> Repo.update()
    |> broadcast_toy_picture_created()
  end

  def delete_toy_picture(%ToyPicture{} = toy_picture) do
    result = Repo.delete(toy_picture)

    broadcast_toy_picture_created({:ok, toy_picture})

    result
  end

  def get_toy_picture!(id), do: Repo.get!(ToyPicture, id)

  defp preload_toy_pictures(query) do
    Repo.preload(query, toy_pictures: from(t in ToyPicture, order_by: t.id))
  end

  defp broadcast_toy_picture_created({:ok, %{document_id: doc_id}} = result) do
    document =
      doc_id
      |> get_document!()
      |> preload_toy_pictures

    broadcast_document({:ok, document}, :update)
    result
  end

  defp broadcast_toy_picture_created(error), do: error
end
