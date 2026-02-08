defmodule GlobalTaskFintech.Domain.StateMachine.CO do
  @moduledoc """
  Colombia-specific state transitions.
  Heavier focus on 'manual_review'.
  """
  @behaviour GlobalTaskFintech.Domain.StateMachine.Workflow

  @impl true
  def initial_state, do: :pending

  @impl true
  def transitions(:pending), do: [:manual_review, :approved, :rejected]
  def transitions(:manual_review), do: [:approved, :rejected]
  def transitions(_), do: []
end
