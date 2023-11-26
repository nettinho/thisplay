defmodule ThisplayWeb.ImageController do
  use ThisplayWeb, :controller

  def uploads(conn, _params) do
    send_resp(conn, :accepted, "")
  end
end
