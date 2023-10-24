defmodule Thisplay.ToysTest do
  use Thisplay.DataCase

  alias Thisplay.Toys

  describe "toys" do
    alias Thisplay.Toys.Toy

    import Thisplay.ToysFixtures

    @invalid_attrs %{name: nil, filename: nil, frequency: nil}

    test "list_toys/0 returns all toys" do
      toy = toy_fixture()
      assert Toys.list_toys() == [toy]
    end

    test "get_toy!/1 returns the toy with given id" do
      toy = toy_fixture()
      assert Toys.get_toy!(toy.id) == toy
    end

    test "create_toy/1 with valid data creates a toy" do
      valid_attrs = %{name: "some name", filename: "some filename", frequency: 42}

      assert {:ok, %Toy{} = toy} = Toys.create_toy(valid_attrs)
      assert toy.name == "some name"
      assert toy.filename == "some filename"
      assert toy.frequency == 42
    end

    test "create_toy/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Toys.create_toy(@invalid_attrs)
    end

    test "update_toy/2 with valid data updates the toy" do
      toy = toy_fixture()
      update_attrs = %{name: "some updated name", filename: "some updated filename", frequency: 43}

      assert {:ok, %Toy{} = toy} = Toys.update_toy(toy, update_attrs)
      assert toy.name == "some updated name"
      assert toy.filename == "some updated filename"
      assert toy.frequency == 43
    end

    test "update_toy/2 with invalid data returns error changeset" do
      toy = toy_fixture()
      assert {:error, %Ecto.Changeset{}} = Toys.update_toy(toy, @invalid_attrs)
      assert toy == Toys.get_toy!(toy.id)
    end

    test "delete_toy/1 deletes the toy" do
      toy = toy_fixture()
      assert {:ok, %Toy{}} = Toys.delete_toy(toy)
      assert_raise Ecto.NoResultsError, fn -> Toys.get_toy!(toy.id) end
    end

    test "change_toy/1 returns a toy changeset" do
      toy = toy_fixture()
      assert %Ecto.Changeset{} = Toys.change_toy(toy)
    end
  end

  describe "filename" do
    alias Thisplay.Toys.Document

    import Thisplay.ToysFixtures

    @invalid_attrs %{}

    test "list_filename/0 returns all filename" do
      document = document_fixture()
      assert Toys.list_filename() == [document]
    end

    test "get_document!/1 returns the document with given id" do
      document = document_fixture()
      assert Toys.get_document!(document.id) == document
    end

    test "create_document/1 with valid data creates a document" do
      valid_attrs = %{}

      assert {:ok, %Document{} = document} = Toys.create_document(valid_attrs)
    end

    test "create_document/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Toys.create_document(@invalid_attrs)
    end

    test "update_document/2 with valid data updates the document" do
      document = document_fixture()
      update_attrs = %{}

      assert {:ok, %Document{} = document} = Toys.update_document(document, update_attrs)
    end

    test "update_document/2 with invalid data returns error changeset" do
      document = document_fixture()
      assert {:error, %Ecto.Changeset{}} = Toys.update_document(document, @invalid_attrs)
      assert document == Toys.get_document!(document.id)
    end

    test "delete_document/1 deletes the document" do
      document = document_fixture()
      assert {:ok, %Document{}} = Toys.delete_document(document)
      assert_raise Ecto.NoResultsError, fn -> Toys.get_document!(document.id) end
    end

    test "change_document/1 returns a document changeset" do
      document = document_fixture()
      assert %Ecto.Changeset{} = Toys.change_document(document)
    end
  end
end
