defmodule GlobalTaskFintech.Infrastructure.Repositories.AuditLogRepository do
  @moduledoc """
  Repository for persisting audit logs.
  """
  alias GlobalTaskFintech.Domain.Models.AuditLog
  alias GlobalTaskFintech.Repo

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
