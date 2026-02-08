defmodule GlobalTaskFintech.Domain.StateMachine.TransitionEngine do
  @moduledoc """
  Core engine for handling state transitions, validations, and side effects.
  """
  require Logger
  alias GlobalTaskFintech.Infrastructure.Jobs.BackgroundJob
  alias GlobalTaskFintech.Infrastructure.Audit.ComplianceAuditor

  @workflows %{
    "MX" => GlobalTaskFintech.Domain.StateMachine.MXWorkflow,
    "CO" => GlobalTaskFintech.Domain.StateMachine.COWorkflow
  }

  def transition(application, next_state, reason \\ nil) do
    workflow = Map.get(@workflows, application.country)

    if valid_transition?(workflow, application.status, next_state) do
      perform_transition(application, next_state, reason)
    else
      {:error, :invalid_transition}
    end
  end

  defp valid_transition?(nil, _, _), do: false

  defp valid_transition?(workflow, current_status, next_status) do
    current_status = ensure_atom(current_status)
    next_status = ensure_atom(next_status)
    allowed = workflow.transitions(current_status)
    next_status in allowed
  end

  defp perform_transition(application, next_state, reason) do
    attrs = %{
      "status" => next_state,
      "risk_reason" => reason || application.risk_reason
    }

    # Transition must be atomic (Update DB)
    case Applications.update_credit_application(application, attrs) do
      {:ok, updated_app} ->
        # Trigger Side Effects
        trigger_side_effects(application.status, updated_app)
        {:ok, updated_app}

      error ->
        error
    end
  end

  defp trigger_side_effects(old_status, new_app) do
    event = %{
      application_id: new_app.id,
      from: old_status,
      to: new_app.status,
      timestamp: DateTime.utc_now()
    }

    # 1. Audit Logging (Asynchronous)
    BackgroundJob.run(ComplianceAuditor, :log_creation, [new_app])

    # 2. Domain Event Emission (Simulation)
    Logger.info("[EVENT] State Transition: #{old_status} -> #{new_app.status} for #{new_app.id}")

    # 3. Country Specific Side Effects
    handle_specific_effects(new_app)
  end

  defp handle_specific_effects(%{country: "MX", status: :risk_check} = _app) do
    Logger.info("[SIDE-EFFECT] MX risk_check triggered. Re-evaluating risk payload...")
    # BackgroundJob.run(GlobalTaskFintech.Domain.Services.EvaluateRisk, :execute, [app])
  end

  defp handle_specific_effects(_), do: :ok

  defp ensure_atom(val) when is_atom(val), do: val
  defp ensure_atom(val) when is_binary(val), do: String.to_existing_atom(val)
end
