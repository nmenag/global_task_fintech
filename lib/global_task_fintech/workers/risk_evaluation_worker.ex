defmodule GlobalTaskFintech.Workers.RiskEvaluationWorker do
  @moduledoc """
  Oban worker for evaluating risk.
  """
  use Oban.Worker,
    queue: :risk,
    max_attempts: 3,
    unique: [period: 300, states: [:available, :scheduled, :retryable]]

  alias GlobalTaskFintech.Applications
  alias GlobalTaskFintech.Domain.Services.EvaluateRisk

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"application_id" => id}}) do
    application = Applications.get_credit_application!(id)

    case EvaluateRisk.execute(application) do
      :ok -> :ok
      {:error, reason} -> {:error, reason}
    end
  end
end
