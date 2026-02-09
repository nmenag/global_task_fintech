defmodule GlobalTaskFintech.Domain.StateMachine.TransitionEngine do
  @moduledoc """
  Core engine for handling state transitions, validations, and side effects.
  """
  require Logger
  alias GlobalTaskFintech.Applications

  @workflows %{
    "MX" => GlobalTaskFintech.Domain.StateMachine.MX,
    "CO" => GlobalTaskFintech.Domain.StateMachine.CO
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

    case Applications.update_credit_application(application, attrs) do
      {:ok, updated_app} ->
        trigger_side_effects(application.status, updated_app)
        {:ok, updated_app}

      error ->
        error
    end
  end

  defp trigger_side_effects(old_status, new_app) do
    Logger.info("[EVENT] State Transition: #{old_status} -> #{new_app.status} for #{new_app.id}")

    handle_specific_effects(new_app)
  end

  defp handle_specific_effects(%{country: "MX", status: :risk_check} = _app) do
    Logger.info("[SIDE-EFFECT] MX risk_check triggered. Re-evaluating risk payload...")
  end

  defp handle_specific_effects(_), do: :ok

  defp ensure_atom(val) when is_atom(val), do: val
  defp ensure_atom(val) when is_binary(val), do: String.to_existing_atom(val)
end
