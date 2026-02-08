defmodule GlobalTaskFintech.Infrastructure.Audit.AuditLogger do
  @moduledoc """
  Handles audit logging for critical application actions.
  """
  require Logger

  def log_creation(application) do
    Logger.info(
      "[AUDIT] Credit Application created: ID=#{application.id}, Country=#{application.country}, Name=#{application.full_name}"
    )

    Process.sleep(500)
    :ok
  end
end
