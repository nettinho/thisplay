defmodule ThisplayWeb.SearchLive do
  use ThisplayWeb, :live_view

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end