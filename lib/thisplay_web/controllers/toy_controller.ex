defmodule ThisplayWeb.ToyController do
  use ThisplayWeb, :controller

  # alias Thisplay.Toys
  # alias Thisplay.Toys.Toy

  # action_fallback ThisplayWeb.FallbackController

  # def index(conn, _params) do
  #   toys = Toys.list_toys()
  #   render(conn, :index, toys: toys)
  # end

  # def create(conn, %{"toy" => toy_params}) do
  #   with {:ok, %Toy{} = toy} <- Toys.create_toy(toy_params) do
  #     conn
  #     |> put_status(:created)
  #     |> put_resp_header("location", ~p"/api/toys/#{toy}")
  #     |> render(:show, toy: toy)
  #   end
  # end

  # def show(conn, %{"id" => id}) do
  #   toy = Toys.get_toy!(id)
  #   render(conn, :show, toy: toy)
  # end

  # def update(conn, %{"id" => id, "toy" => toy_params}) do
  #   toy = Toys.get_toy!(id)

  #   with {:ok, %Toy{} = toy} <- Toys.update_toy(toy, toy_params) do
  #     render(conn, :show, toy: toy)
  #   end
  # end

  # def delete(conn, %{"id" => id}) do
  #   toy = Toys.get_toy!(id)

  #   with {:ok, %Toy{}} <- Toys.delete_toy(toy) do
  #     send_resp(conn, :no_content, "")
  #   end
  # end
end
