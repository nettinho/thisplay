defmodule ThisplayWeb.DocumentJSON do
  alias Thisplay.Toys.Document

  @doc """
  Renders a list of filename.
  """
  def index(%{filename: filename}) do
    %{data: for(document <- filename, do: data(document))}
  end

  @doc """
  Renders a single document.
  """
  def show(%{document: document}) do
    %{data: data(document)}
  end

  defp data(%Document{} = document) do
    %{
      id: document.id
    }
  end
end
