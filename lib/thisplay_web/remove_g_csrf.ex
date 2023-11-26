defmodule ThisplayWeb.Plug.RemoveGCsrf do
  @moduledoc """
  Plug to check the CSRF state concordance when receiving data from Google.

  Denies to treat the HTTP request if fails.
  """
  import Plug.Conn
  use ThisplayWeb, :verified_routes

  def init(opts), do: opts

  def call(conn, _opts) do
    delete_resp_cookie(conn, "g_csrf_token")
  end
end
