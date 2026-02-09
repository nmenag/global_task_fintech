defmodule GlobalTaskFintech.Infrastructure.Jobs.BackgroundJob do
  @moduledoc """
  Simple background job dispatcher using Elixir Tasks.
  This allows us to trigger side effects without blocking the main process.
  """
  require Logger

  def run(module, function, args) do
    Task.Supervisor.start_child(GlobalTaskFintech.TaskSupervisor, fn ->
      try do
        apply(module, function, args)
      rescue
        e ->
          Logger.error("Background job failed: #{inspect(module)}.#{function} with #{inspect(e)}")
      end
    end)
  end
end
