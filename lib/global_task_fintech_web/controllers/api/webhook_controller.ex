defmodule GlobalTaskFintechWeb.Api.WebhookController do
  use GlobalTaskFintechWeb, :controller
  require Logger

  alias GlobalTaskFintech.Applications
  alias GlobalTaskFintech.Domain.StateMachine.TransitionEngine

  action_fallback GlobalTaskFintechWeb.FallbackController

  @doc """
  Receives and processes application status updates.
  Expects: %{"application_id" => id, "status" => status, "reason" => reason}
  """
  def receive(conn, %{"application_id" => id, "status" => status} = params) do
    Logger.info("[WEBHOOK] Received status update for #{id} -> #{status}")
    reason = Map.get(params, "reason", "Updated via Webhook")

    with {:ok, application} <- fetch_application(id),
         {:ok, _status_atom} <- validate_status(status),
         {:ok, _updated} <- TransitionEngine.transition(application, status, reason) do
      conn
      |> put_status(:ok)
      |> json(%{status: "success", message: "Application status updated"})
    end
  end

  def receive(_conn, _params), do: {:error, :bad_request}

  defp fetch_application(id) do
    case Applications.get_credit_application(id) do
      nil -> {:error, :not_found}
      app -> {:ok, app}
    end
  end

  defp validate_status(status) do
    try do
      {:ok, String.to_existing_atom(status)}
    rescue
      ArgumentError -> {:error, "Invalid status value: #{status}"}
    end
  end
end
