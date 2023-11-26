defmodule ThisplayWeb.DocumentController do
  use ThisplayWeb, :controller

  # alias Thisplay.Toys
  # alias Thisplay.Toys.Document

  # action_fallback ThisplayWeb.FallbackController

  # def index(conn, _params) do
  #   filename = Toys.list_filename()
  #   render(conn, :index, filename: filename)
  # end

  # def create(conn, %{"document" => document_params}) do
  #   with {:ok, %Document{} = document} <- Toys.create_document(document_params) do
  #     conn
  #     |> put_status(:created)
  #     |> put_resp_header("location", ~p"/api/filename/#{document}")
  #     |> render(:show, document: document)
  #   end
  # end

  # def show(conn, %{"id" => id}) do
  #   document = Toys.get_document!(id)
  #   render(conn, :show, document: document)
  # end

  # def update(conn, %{"id" => id, "document" => document_params}) do
  #   document = Toys.get_document!(id)

  #   with {:ok, %Document{} = document} <- Toys.update_document(document, document_params) do
  #     render(conn, :show, document: document)
  #   end
  # end

  # def delete(conn, %{"id" => id}) do
  #   document = Toys.get_document!(id)

  #   with {:ok, %Document{}} <- Toys.delete_document(document) do
  #     send_resp(conn, :no_content, "")
  #   end
  # end
end
