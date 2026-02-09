defmodule GlobalTaskFintech.Workers.WebhookWorker do
  @moduledoc """
  Oban worker for delivering webhooks.
  """
  use Oban.Worker, queue: :webhooks, max_attempts: 5

  alias GlobalTaskFintech.Applications
  alias GlobalTaskFintech.Infrastructure.Webhooks.WebhookService

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"application_id" => id}}) do
    application = Applications.get_credit_application!(id)

    case WebhookService.notify_status_change(application) do
      :ok -> :ok
      {:error, reason} -> {:error, reason}
    end
  end
end
