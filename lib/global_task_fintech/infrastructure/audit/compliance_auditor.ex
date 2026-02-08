defmodule GlobalTaskFintech.Infrastructure.Audit.ComplianceAuditor do
  @moduledoc """
  Handles audit logging and compliance tracking for critical application actions.
  """
  require Logger

  def log_creation(application) do
    Logger.info(
      "[COMPLIANCE] Credit Application created: ID=#{application.id}, Country=#{application.country}, Name=#{application.full_name}"
    )

    # Simulate persistence or external call
    Process.sleep(500)
    :ok
  end
end
