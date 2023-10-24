defmodule ThisplayWeb.ImageController do
  use ThisplayWeb, :controller

  def uploads(conn, params) do
    send_resp(conn, :accepted, "")
  end
end
