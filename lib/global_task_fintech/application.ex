defmodule GlobalTaskFintech.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      GlobalTaskFintechWeb.Telemetry,
      GlobalTaskFintech.Repo,
      {DNSCluster,
       query: Application.get_env(:global_task_fintech, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: GlobalTaskFintech.PubSub},
      # Start a worker by calling: GlobalTaskFintech.Worker.start_link(arg)
      # {GlobalTaskFintech.Worker, arg},
      # Start to serve requests, typically the last entry
      GlobalTaskFintechWeb.Endpoint,
      {Task.Supervisor, name: GlobalTaskFintech.TaskSupervisor}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: GlobalTaskFintech.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    GlobalTaskFintechWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
