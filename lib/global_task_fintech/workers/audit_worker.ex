defmodule GlobalTaskFintech.Workers.AuditWorker do
  @moduledoc """
  Oban worker for persisting audit logs.
  """
  use Oban.Worker, queue: :default, max_attempts: 10

  alias GlobalTaskFintech.Infrastructure.Repositories.AuditLogRepository

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"attrs" => attrs}}) do
    case AuditLogRepository.log(attrs) do
      {:ok, _log} -> :ok
      {:error, reason} -> {:error, reason}
    end
  end
end
