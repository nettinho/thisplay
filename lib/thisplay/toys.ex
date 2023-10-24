defmodule Thisplay.Toys do
  @moduledoc """
  The Toys context.
  """

  import Ecto.Query, warn: false
  alias Thisplay.Repo

  alias Thisplay.Toys.Toy

  @doc """
  Returns the list of toys.

  ## Examples

      iex> list_toys()
      [%Toy{}, ...]

  """
  def list_toys do
    Repo.all(Toy)
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
    # IO.inspect(attrs)

    # toy_exists? =
    #   %Toy{}
    #   |> Repo.get(:name, Map.get(attrs, :name))

    %Toy{}
    |> Toy.changeset(attrs)
    |> Repo.insert()
    |> dbg()
  end

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
  def get_document!(id), do: Repo.get!(Document, id) |> Repo.preload(:toys)

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
end
