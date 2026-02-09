defmodule GlobalTaskFintech.Infrastructure.Repositories.AuditLogRepository do
  alias GlobalTaskFintech.Repo
  alias GlobalTaskFintech.Domain.Models.AuditLog

  require Logger

  def log(attrs) do
    %AuditLog{}
    |> AuditLog.changeset(attrs)
    |> Repo.insert()
    |> case do
      {:ok, log} ->
        {:ok, log}

      {:error, changeset} ->
        Logger.error("Failed to persist audit log: #{inspect(changeset.errors)}")
        {:error, changeset}
    end
  end
end
