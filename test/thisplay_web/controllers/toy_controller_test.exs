defmodule ThisplayWeb.ToyControllerTest do
  use ThisplayWeb.ConnCase

  import Thisplay.ToysFixtures

  alias Thisplay.Toys.Toy

  @create_attrs %{
    name: "some name",
    filename: "some filename",
    frequency: 42
  }
  @update_attrs %{
    name: "some updated name",
    filename: "some updated filename",
    frequency: 43
  }
  @invalid_attrs %{name: nil, filename: nil, frequency: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all toys", %{conn: conn} do
      conn = get(conn, ~p"/api/toys")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create toy" do
    test "renders toy when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/toys", toy: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/toys/#{id}")

      assert %{
               "id" => ^id,
               "filename" => "some filename",
               "frequency" => 42,
               "name" => "some name"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/toys", toy: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update toy" do
    setup [:create_toy]

    test "renders toy when data is valid", %{conn: conn, toy: %Toy{id: id} = toy} do
      conn = put(conn, ~p"/api/toys/#{toy}", toy: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/toys/#{id}")

      assert %{
               "id" => ^id,
               "filename" => "some updated filename",
               "frequency" => 43,
               "name" => "some updated name"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, toy: toy} do
      conn = put(conn, ~p"/api/toys/#{toy}", toy: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete toy" do
    setup [:create_toy]

    test "deletes chosen toy", %{conn: conn, toy: toy} do
      conn = delete(conn, ~p"/api/toys/#{toy}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/toys/#{toy}")
      end
    end
  end

  defp create_toy(_) do
    toy = toy_fixture()
    %{toy: toy}
  end
end
