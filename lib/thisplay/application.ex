defmodule Thisplay.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      ThisplayWeb.Telemetry,
      Thisplay.Repo,
      {DNSCluster, query: Application.get_env(:thisplay, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Thisplay.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Thisplay.Finch},
      # Start a worker by calling: Thisplay.Worker.start_link(arg)
      # {Thisplay.Worker, arg},
      # Start to serve requests, typically the last entry
      ThisplayWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Thisplay.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ThisplayWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
