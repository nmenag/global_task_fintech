defmodule GlobalTaskFintech.Domain.Services.EvaluateRisk do
  @moduledoc """
  Performs risk evaluation on a credit application.
  Integrates with the external Rules Engine asynchronously.
  """
  require Logger
  alias GlobalTaskFintech.Domain.StateMachine.TransitionEngine
  alias GlobalTaskFintech.Infrastructure.Rules.BusinessRulesClient

  def execute(application) do
    Logger.info("[RISK] Starting risk evaluation for application #{application.id}")

    bank_data = application.bank_data || %{}

    payload = %{
      "country" => application.country,
      "document_type" => String.upcase(application.document_type || ""),
      "document_number" => application.document_number,
      "monthly_income" => application.monthly_income,
      "amount_requested" => application.amount_requested,
      "total_debt" => bank_data["total_debt"] || 0,
      "credit_score" => bank_data["credit_score"]
    }

    case BusinessRulesClient.evaluate(payload, "credit_risk") do
      {:ok, %{"decision" => decision, "reason" => reason}} ->
        Logger.info("[RISK] Decision: #{decision}, Reason: #{reason}")
        status = get_status(decision)
        update_status(application, status, reason)

      {:ok, result} ->
        Logger.warning("[RISK] Unexpected response from rules engine: #{inspect(result)}")
        update_status(application, "pending", "Unexpected engine response")

      {:error, reason} ->
        Logger.error("[RISK] Failed to evaluate risk for #{application.id}: #{inspect(reason)}")
        update_status(application, "pending", "Engine error: #{inspect(reason)}")
        {:error, reason}
    end
  end

  defp get_status("approve"), do: "approved"
  defp get_status(_), do: "rejected"

  defp update_status(application, status, reason) do
    case TransitionEngine.transition(application, status, reason) do
      {:ok, _updated} ->
        Logger.info("[RISK] Risk evaluation finished for #{application.id}. Status: #{status}")
        :ok

      {:error, reason} ->
        Logger.error("[RISK] State transition failed for #{application.id}: #{inspect(reason)}")
        {:error, reason}
    end
  end
end
