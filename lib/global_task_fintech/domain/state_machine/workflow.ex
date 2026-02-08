defmodule GlobalTaskFintech.Domain.StateMachine.Workflow do
  @moduledoc """
  Behavior for country-specific credit application workflows.
  """
  @callback transitions(current_state :: atom()) :: [atom()]
  @callback initial_state() :: atom()
end
