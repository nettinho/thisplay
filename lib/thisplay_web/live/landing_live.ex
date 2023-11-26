defmodule ThisplayWeb.LandingLive do
  use ThisplayWeb, :live_view

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    g_cb_uri = System.get_env("GOOGLE_REDIRECT", "https://thisplay.fly.dev/g_cb_uri")
    g_client_id = System.get_env("GOOGLE_CLIENT_ID")

    {:ok,
     socket
     |> assign(:g_cb_uri, g_cb_uri)
     |> assign(:g_client_id, g_client_id)}
  end
end
