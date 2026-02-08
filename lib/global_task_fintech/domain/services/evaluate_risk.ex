defmodule GlobalTaskFintech.Domain.Services.EvaluateRisk do
  @moduledoc """
  Performs risk evaluation on a credit application.
  Integrates with the external Rules Engine asynchronously.
  """
  require Logger
  alias GlobalTaskFintech.Applications
  alias GlobalTaskFintech.Infrastructure.Rules.BusinessRulesClient

  def execute(application) do
    Logger.info("[RISK] Starting risk evaluation for application #{application.id}")

    payload = %{
      "country" => application.country,
      "monthly_income" => application.monthly_income,
      "amount_requested" => application.amount_requested,
      "credit_score" => application.bank_data["credit_score"]
    }

    case BusinessRulesClient.evaluate(payload) do
      {:ok, %{"decision" => decision}} ->
        status = get_status(decision)
        update_status(application, status)

      {:ok, result} ->
        Logger.warning("[RISK] Unexpected response from rules engine: #{inspect(result)}")
        update_status(application, "pending")

      {:error, reason} ->
        Logger.error("[RISK] Failed to evaluate risk for #{application.id}: #{inspect(reason)}")
        :error
    end
  end

  defp get_status("approved"), do: "approved"
  defp get_status(_), do: "rejected"

  defp update_status(application, status) do
    Applications.update_credit_application(application, %{"status" => status})
    Logger.info("[RISK] Risk evaluation finished for #{application.id}. Status: #{status}")
    :ok
  end
end
