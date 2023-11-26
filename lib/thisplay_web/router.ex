defmodule ThisplayWeb.Router do
  use ThisplayWeb, :router

  import ThisplayWeb.UserAuth

  alias ThisplayWeb.Plug.CheckCsrf
  alias ThisplayWeb.Plug.RemoveGCsrf

  pipeline :google do
    plug Plug.Parsers, parsers: [:urlencoded], pass: ["text/html"]
    plug CheckCsrf
    plug :fetch_session
    plug :fetch_live_flash
  end

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {ThisplayWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
    plug RemoveGCsrf
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ThisplayWeb do
    pipe_through :google

    post "/g_cb_uri", OneTapController, :login
  end

  scope "/", ThisplayWeb do
    pipe_through :browser

    get("/uploads/:image", ImageController, :uploads)
  end

  # Other scopes may use custom stacks.
  scope "/api", ThisplayWeb do
    pipe_through :api
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:thisplay, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: ThisplayWeb.Telemetry
    end
  end

  ## Authentication routes

  scope "/", ThisplayWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{ThisplayWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live "/landing", LandingLive
    end
  end

  scope "/", ThisplayWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{ThisplayWeb.UserAuth, :ensure_authenticated}] do
      live "/", HomeLive
      live "/list", ListLive
      live "/upload/:id", UploadLive
      live "/toys/:id", ToysLive
      live "/search", SearchLive
      live "/detail/:id", DetailLive
    end
  end

  scope "/", ThisplayWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete
  end
end
