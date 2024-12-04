defmodule SnakeGame.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      SnakeGameWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:snake_game, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: SnakeGame.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: SnakeGame.Finch},
      # Start a worker by calling: SnakeGame.Worker.start_link(arg)
      # {SnakeGame.Worker, arg},
      SnakeGameWeb.Endpoint,
      # Start to serve requests, typically the last entry
      # 启动 GameServer，不需要特殊参数
      {SnakeGame.GameServer, nil}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: SnakeGame.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    SnakeGameWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
