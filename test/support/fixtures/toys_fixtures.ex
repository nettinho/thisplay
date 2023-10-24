defmodule Thisplay.ToysFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Thisplay.Toys` context.
  """

  @doc """
  Generate a toy.
  """
  def toy_fixture(attrs \\ %{}) do
    {:ok, toy} =
      attrs
      |> Enum.into(%{
        filename: "some filename",
        frequency: 42,
        name: "some name"
      })
      |> Thisplay.Toys.create_toy()

    toy
  end

  @doc """
  Generate a document.
  """
  def document_fixture(attrs \\ %{}) do
    {:ok, document} =
      attrs
      |> Enum.into(%{

      })
      |> Thisplay.Toys.create_document()

    document
  end
end
