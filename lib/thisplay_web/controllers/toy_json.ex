defmodule ThisplayWeb.ToyJSON do
  alias Thisplay.Toys.Toy

  @doc """
  Renders a list of toys.
  """
  def index(%{toys: toys}) do
    %{data: for(toy <- toys, do: data(toy))}
  end

  @doc """
  Renders a single toy.
  """
  def show(%{toy: toy}) do
    %{data: data(toy)}
  end

  defp data(%Toy{} = toy) do
    %{
      id: toy.id,
      name: toy.name,
      frequency: toy.frequency
    }
  end
end
