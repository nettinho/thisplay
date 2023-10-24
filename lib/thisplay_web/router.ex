defmodule ThisplayWeb.Router do
  use ThisplayWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {ThisplayWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ThisplayWeb do
    pipe_through :browser

    # live_session :session, on_mount: ThisplayWeb.Session do
    live "/", HomeLive
    live "/list", ListLive
    live "/upload/:id", UploadLive
    live "/search", SearchLive
    live "/detail", DetailLive
    # end

    get("/uploads/:image", ImageController, :uploads)
  end

  # Other scopes may use custom stacks.
  scope "/api", ThisplayWeb do
    pipe_through :api

    resources "/filename", DocumentController, except: [:new, :edit]
    resources "/toys", ToyController, except: [:new, :edit]
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
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
