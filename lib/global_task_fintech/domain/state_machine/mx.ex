defmodule GlobalTaskFintech.Domain.StateMachine.MX do
  @moduledoc """
  Mexico-specific state transitions.
  Includes a 'risk_check' intermediate state.
  """
  @behaviour GlobalTaskFintech.Domain.StateMachine.Workflow

  @impl true
  def initial_state, do: :pending

  @impl true
  def transitions(:pending), do: [:risk_check, :approved, :rejected]
  def transitions(:risk_check), do: [:approved, :rejected, :manual_review]
  def transitions(:manual_review), do: [:approved, :rejected]
  def transitions(_), do: []
end
